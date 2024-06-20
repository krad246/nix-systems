{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  triple = lib.strings.splitString "-" pkgs.stdenv.system;
  uname = builtins.elemAt triple 0;
  maybeRosetta =
    if pkgs.stdenv.isDarwin
    then "--vm-type vz --vz-rosetta"
    else "";
  mkScript = arch:
    pkgs.writeShellScript "colima-${arch}-start" ''
      ${lib.getExe pkgs.colima} start \
        -p ${arch} \
        --arch ${arch} \
        --disk 16 \
        --cpu 8 --memory 8 \
        --verbose \
        --foreground ${maybeRosetta}
    '';

  nixosPathCfg = lib.attrsets.attrByPath ["system" "path"] "" osConfig;
  darwinPathCfg = lib.attrsets.attrByPath ["environment" "systemPath"] "" osConfig;
  homePathCfg = lib.strings.concatStringsSep ":" config.home.sessionPath;

  linuxPath = lib.strings.concatStringsSep ":" ["${homePathCfg}" "${lib.makeBinPath [nixosPathCfg]}"];
  darwinPath = lib.strings.concatStringsSep ":" ["${homePathCfg}" "${darwinPathCfg}"];
  mkSystemdService = script: arch:
    lib.mkIf pkgs.stdenv.isLinux {
      systemd.user.services."colima-${arch}-autostart" = {
        Unit = {
          Description = "Start Colima ${arch} VM.";
        };
        Install = {
          WantedBy = ["default.target"];
        };
        Service = {
          ExecStart = "${script}";
          Environment = ["PATH=${linuxPath}"];
        };
      };
    };

  mkLaunchUnit = script: arch:
    lib.mkIf pkgs.stdenv.isDarwin {
      launchd.agents."colima-${arch}-autostart" = {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = "${darwinPath}";
          };
          Program = "${script}";
          ProgramArguments = ["${script}"];
          RunAtLoad = true;
          KeepAlive = true;
        };
      };
    };

  mkUnits = arch: let script = mkScript arch; in lib.mkMerge [(mkSystemdService script arch) (mkLaunchUnit script arch)];
in {
  home.packages = with pkgs; [colima docker];
  home.sessionPath = ["${lib.makeBinPath [pkgs.docker]}"];
  imports = [
    (_: mkUnits uname)
  ];
}

{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  vmConfig =
    lib.attrsets.attrByPath ["virtualisation"] {
      cores = 2;

      darwin-builder = {
        memorySize = 4 * 1024;
        diskSize = 8 * 1024;
      };
    }
    osConfig;
  mkScript = arch:
    pkgs.writeShellScript "colima-${arch}" ''
      ${lib.getExe pkgs.colima} start \
        -p ${arch} \
        --arch ${arch} \
        --disk ${builtins.toString (vmConfig.darwin-builder.diskSize / 1024)} \
        --cpu ${builtins.toString vmConfig.cores} \
        --memory ${builtins.toString (vmConfig.darwin-builder.memorySize / 1024)} \
        --verbose \
        --foreground --vm-type vz --vz-rosetta
    '';

  darwinPathCfg = lib.attrsets.attrByPath ["environment" "systemPath"] "" osConfig;
  homePathCfg = lib.strings.concatStringsSep ":" config.home.sessionPath;
  darwinPath = lib.strings.concatStringsSep ":" ["${homePathCfg}" "${darwinPathCfg}"];

  mkLaunchUnit = arch: let
    script = mkScript arch;
  in
    lib.mkIf pkgs.stdenv.isDarwin {
      launchd.agents."colima-${arch}" = {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = "${darwinPath}";
          };
          Program = "${script}";
          ProgramArguments = ["${script}"];
          RunAtLoad = true;
          KeepAlive = true;

          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/colima-${arch}/stdout";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/colima-${arch}/stderr";
        };
      };
    };

  parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
in {
  home.packages = with pkgs; [colima docker];
  home.sessionPath = ["${lib.makeBinPath [pkgs.docker]}"];
  imports = [
    (mkLaunchUnit parse.cpu.name)
  ];
}

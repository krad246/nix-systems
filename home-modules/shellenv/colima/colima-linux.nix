{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  vmConfig = {
    cores = 2;
    memorySize = 2 * 1024;
    diskSize = 8 * 1024;
  };

  mkScript = arch:
    pkgs.writeShellScript "colima-${arch}" ''
      ${lib.getExe pkgs.colima} start \
        -p ${arch} \
        --arch ${arch} \
        --disk ${builtins.toString (vmConfig.diskSize / 1024)} \
        --cpu ${builtins.toString vmConfig.cores} \
        --memory ${builtins.toString (vmConfig.memorySize / 1024)} \
        --verbose
    '';

  nixosPathCfg = lib.attrsets.attrByPath ["system" "path"] "" osConfig;
  homePathCfg = lib.strings.concatStringsSep ":" config.home.sessionPath;

  linuxPath = lib.strings.concatStringsSep ":" ["${homePathCfg}" "${lib.makeBinPath [nixosPathCfg]}"];
  mkSystemdService = arch: let
    script = mkScript arch;
  in
    lib.mkIf pkgs.stdenv.isLinux {
      systemd.user.services = {
        "colima-${arch}" = {
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
    };

  dockerContextUse = arch:
    lib.mkIf pkgs.stdenv.isLinux {
      systemd.user.services = {
        "docker-context-use-colima-${arch}" = {
          Unit = {
            Description = "Start Colima ${arch} VM.";
            After = ["colima-${arch}.service"];
            BindsTo = ["colima-${arch}.service"];
          };
          Install = {
            WantedBy = ["colima-${arch}.service"];
          };
          Service = {
            ExecStart = "docker context use colima-${arch}";
            Environment = ["PATH=${linuxPath}"];
          };
        };
      };
    };

  parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
in {
  home.packages = with pkgs; [colima docker];
  imports =
    [
      (mkSystemdService "aarch64")
      (mkSystemdService "x86_64")
    ]
    ++ [
      (dockerContextUse parse.cpu.name)
    ];
}

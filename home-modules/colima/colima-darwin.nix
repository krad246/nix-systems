{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  vmConfig =
    lib.attrsets.attrByPath ["virtualisation"] {
      cores = 8;

      darwin-builder = {
        memorySize = 8 * 1024;
        diskSize = 32 * 1024;
      };
    }
    osConfig;
  mkScript = arch:
    pkgs.writeShellApplication {
      name = "colima-${arch}";
      text = ''
        colima version --verbose
        colima start \
          -p ${arch} \
          --arch ${arch} \
          --disk ${builtins.toString (vmConfig.darwin-builder.diskSize / 1024)} \
          --cpu ${builtins.toString vmConfig.cores} \
          --memory ${builtins.toString (vmConfig.darwin-builder.memorySize / 1024)} \
          --verbose \
          --vm-type vz \
          --vz-rosetta \
          --foreground
      '';
    };

  mkLaunchUnit = arch: let
    script = lib.getExe (mkScript arch);
  in
    lib.mkIf pkgs.stdenv.isDarwin {
      launchd.agents."colima-${arch}" = {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = lib.strings.concatStringsSep ":" [
              (lib.makeBinPath [pkgs.colima])
              osConfig.environment.systemPath
            ];
          };
          Program = "${script}";
          RunAtLoad = true;
          KeepAlive = true;
        };
      };
    };

  parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
in {
  imports = [
    (mkLaunchUnit parse.cpu.name)
  ];
}

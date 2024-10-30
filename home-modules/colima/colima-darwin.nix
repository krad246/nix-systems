{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  vmConfig = {
    cores = 8;
    darwin-builder = {
      memorySize = 8 * 1024;
      diskSize = 80 * 1024;
    };
  };

  mkScript = arch:
    pkgs.writeShellApplication {
      name = "colima-${arch}";
      text = ''
        if ! colima status -p ${arch}; then
          if ! colima restart -p ${arch}; then
            colima start -p ${arch} \
              --env TERM=xterm-256color \
              --arch ${arch} \
              --disk ${builtins.toString (vmConfig.darwin-builder.diskSize / 1024)} \
              --cpu ${builtins.toString vmConfig.cores} \
              --memory ${builtins.toString (vmConfig.darwin-builder.memorySize / 1024)} \
              --verbose \
              --vm-type vz \
              --vz-rosetta \
              --foreground
          fi
        fi
      '';
    };

  mkLaunchUnit = arch: let
    script = lib.getExe (mkScript arch);
  in
    lib.mkIf pkgs.stdenv.isDarwin {
      home.packages = [pkgs.colima];
      launchd.agents."colima-${arch}" = {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = lib.strings.concatStringsSep ":" [
              (lib.makeBinPath [pkgs.colima])

              # required for colima to call macOS commands to enable rosetta.
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

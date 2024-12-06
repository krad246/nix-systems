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
      runtimeInputs = [pkgs.colima pkgs.docker];
      name = "colima-${arch}";
      text = let
        args = lib.cli.toGNUCommandLine {} {
          env = "TERM=xterm-256color";
          inherit arch;
          disk = vmConfig.darwin-builder.diskSize / 1024;
          cpu = vmConfig.cores;
          memory = vmConfig.darwin-builder.memorySize;
          verbose = true;
          vm-type = "vz";
          vz-rosetta = true;
          foreground = true;
        };
      in ''
        if ! colima status -p ${arch}; then
          if ! colima restart -p ${arch}; then
            colima start -p ${arch} ${lib.strings.concatStringsSep " " args}
          fi
        fi
      '';
    };

  mkLaunchUnit = arch: let
    script = lib.meta.getExe (mkScript arch);
  in
    lib.modules.mkIf pkgs.stdenv.isDarwin {
      home.packages = [pkgs.colima pkgs.docker];

      launchd.agents."colima-${arch}" = {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = lib.strings.concatStringsSep ":" [
              (lib.strings.makeBinPath [pkgs.colima pkgs.docker])

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

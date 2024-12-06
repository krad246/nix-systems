{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) cli meta strings systems;

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
      runtimeInputs = [pkgs.colima];
      text = let
        args = cli.toGNUCommandLineShell {} {
          env = "TERM=xterm-256color";
          inherit arch;
          disk = builtins.toString (vmConfig.darwin-builder.diskSize / 1024);
          cpu = builtins.toString vmConfig.cores;
          memory = builtins.toString (vmConfig.darwin-builder.memorySize / 1024);
          verbose = true;
          vm-type = "vz";
          vz-rosetta = true;
          foreground = true;
        };
      in ''
        if ! colima status -p ${arch}; then
          if ! colima restart -p ${arch}; then
            colima start -p ${arch} ${args}
          fi
        fi
      '';
    };

  mkLaunchUnit = arch: let
    script = meta.getExe (mkScript arch);
    inherit (lib) modules;
  in
    modules.mkIf pkgs.stdenv.isDarwin {
      home.packages = [pkgs.colima pkgs.docker];

      launchd.agents."colima-${arch}" = {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = strings.concatStringsSep ":" [
              (strings.makeBinPath [pkgs.colima pkgs.docker])

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

  parse = systems.parse.mkSystemFromString pkgs.stdenv.system;
in {
  imports = [
    (mkLaunchUnit parse.cpu.name)
  ];
}

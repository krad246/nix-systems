{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.krad246.darwin.colima;

  inherit (lib) modules options types;
in {
  options = {
    krad246.darwin.colima = {
      enable = options.mkEnableOption "colima";

      cores = options.mkOption {
        type = types.ints.positive;
        default = 8;
        description = ''
          Specify the number of cores the guest is permitted to use.
          The number can be higher than the available cores on the
          host system.
        '';
      };

      memorySize = options.mkOption {
        default = 6 * 1024;
        type = types.ints.positive;
        example = 8192;
        description = "The runner's memory in MB";
      };

      diskSize = options.mkOption {
        default = 32 * 1024;
        type = types.ints.positive;
        example = 30720;
        description = "The maximum disk space allocated to the runner in MB";
      };
    };
  };

  config = let
    parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
    arch = parse.cpu.name;

    script = pkgs.writeShellApplication {
      runtimeInputs = [pkgs.colima pkgs.docker];
      name = "colima-${arch}";
      text = let
        args = lib.cli.toGNUCommandLine {} {
          env = "TERM=xterm-256color";
          inherit arch;
          disk = cfg.diskSize / 1024;
          cpu = cfg.cores;
          memory = cfg.memorySize / 1024;
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
  in
    modules.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [colima docker];
      launchd.agents = lib.modules.mkIf pkgs.stdenv.isDarwin {
        "colima-${arch}" = {
          serviceConfig = {
            EnvironmentVariables = {
              PATH = lib.strings.concatStringsSep ":" [
                (lib.strings.makeBinPath [pkgs.colima pkgs.docker])

                # required for colima to call macOS commands to enable rosetta.
                config.environment.systemPath
              ];
            };
            Program = "${lib.meta.getExe script}";
            RunAtLoad = true;
            KeepAlive = true;
          };
        };
      };
    };
}

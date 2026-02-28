{
  flake.modules.homeManager.fzf = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.shell.programs.fzf;
  in {
    options = {
      shell.programs.fzf = {
        defaultCommand = {
          package = lib.options.mkPackageOption pkgs "fd";
          args = lib.options.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "fd --type f";
            description = ''
              Args passed to the command that gets executed as the default source for fzf
              when running.
            '';
          };
        };
      };
    };

    config = {
      programs.fzf = {
        defaultCommand = lib.strings.concatStringsSep " " [
          (lib.meta.getExe cfg.defaultCommand.package)
          cfg.defaultCommand.args
        ];

        defaultOptions =
          lib.cli.toGNUCommandLine {}
          {
            height = "~100%";
            multi = true;
            highlight-line = true;
            cycle = true;
            wrap = true;
            track = true;
            filepath-word = true;
          };
      };
    };
  };
}

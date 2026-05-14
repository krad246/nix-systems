{lib, ...}: {
  flake.modules.homeManager.pager = {config, ...}: let
    cfg = config.shell.programs.pager;
  in {
    options.shell.programs.pager.enable = lib.options.mkEnableOption "Whether to enable an augmented `PAGER` program.";

    config = lib.modules.mkIf cfg.enable {
      programs = {
        less = {
          enable = true;
          config = ''
          '';
        };

        lesspipe.enable = lib.modules.mkDefault true;
      };

      # -I: ignore-case
      # -F: quit-if-one-screen
      # -R: raw-control-characters
      # -K: quit-on-intr
      # -s: squeeze-blank-lines
      home.sessionVariables = {
        LESS = "-IFRKs";
        PAGER = "less";
      };
    };
  };
}

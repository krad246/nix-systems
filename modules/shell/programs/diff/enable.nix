{
  flake.modules.homeManager.diff = {
    config,
    lib,
    ...
  }: let
    cfg = config.shell.programs.diff;
  in {
    options.shell.programs.diff = {
      enable =
        lib.options.mkEnableOption "Whether to enable an augmented `diff` program.";

      integrations = {
        git.enable =
          lib.options.mkEnableOption "Whether to enable diff `git` integration.";
        lazygit.enable =
          lib.options.mkEnableOption "Whether to enable diff `lazygit` integration.";
      };
    };

    config.shell.programs.diff.backends.delta = lib.modules.mkIf cfg.enable {
      enable = lib.modules.mkDefault true;
      integrations = {
        git.enable = lib.modules.mkDefault cfg.integrations.git.enable;
        lazygit.enable = lib.modules.mkDefault cfg.integrations.lazygit.enable;
      };
    };
  };
}

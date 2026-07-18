{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.shell = {
    config,
    options,
    ...
  }: let
    cfg = config.shell;
  in {
    imports = with self.modules.homeManager; [
      bat
      bottom
      diff
      fd
      lsd
      man
      pager
      picker
      ripgrep
      starship
      yazi
      zoxide
    ];

    options.shell = {
      integrations = {
        bat.enable = lib.options.mkEnableOption "Whether to enable shell `bat` integration.";
        direnv.enable = lib.options.mkEnableOption "Whether to enable shell `direnv` integration.";
        fzf.enable = lib.options.mkEnableOption "Whether to enable shell `fzf` integration.";
        lsd.enable = lib.options.mkEnableOption "Whether to enable shell `lsd` integration.";
        kitty.enable = lib.options.mkEnableOption "Whether to enable shell `kitty` integration.";
        starship.enable = lib.options.mkEnableOption "Whether to enable shell `starship` integration.";
        yazi.enable = lib.options.mkEnableOption "Whether to enable shell `yazi` integration.";
        zoxide.enable = lib.options.mkEnableOption "Whether to enable shell `zoxide` integration.";
      };
    };

    config = lib.modules.mkMerge [
      {
        shell = {
          backends.bash.integrations.batpipe.enable = cfg.programs.pager.integrations.bat.enable;

          programs = {
            bat.integrations.delta.enable = lib.modules.mkDefault cfg.programs.diff.backends.delta.enable;

            man.integrations.bat.enable = lib.modules.mkDefault cfg.integrations.bat.enable;
            pager.integrations.bat.enable = lib.modules.mkDefault cfg.integrations.bat.enable;
            ripgrep.integrations.bat.enable = lib.modules.mkDefault cfg.integrations.bat.enable;
          };
        };
      }
      (lib.modules.mkIf (options ? terminal.backends.kitty.enable) {
        shell.integrations.kitty.enable = lib.modules.mkDefault config.terminal.backends.kitty.enable;
      })
    ];
  };
}

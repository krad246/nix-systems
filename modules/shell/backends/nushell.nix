{lib, ...}: {
  flake.modules.homeManager.shell = {config, ...}: let
    cfg = config.shell;
  in {
    options.shell.backends.nushell = {
      enable = lib.options.mkEnableOption "Whether to manage `nushell`.";
      integrations = {
        direnv.enable =
          lib.options.mkEnableOption "Whether to enable the `direnv` integration for `nushell`."
          // {
            default = cfg.integrations.direnv.enable;
          };
        starship.enable =
          lib.options.mkEnableOption "Whether to enable the `starship` integration for `nushell`."
          // {
            default = cfg.integrations.starship.enable;
          };
        yazi.enable =
          lib.options.mkEnableOption "Whether to enable the `yazi` integration for `nushell`."
          // {
            default = cfg.integrations.yazi.enable;
          };
        zoxide.enable =
          lib.options.mkEnableOption "Whether to enable the `zoxide` integration for `nushell`."
          // {
            default = cfg.integrations.zoxide.enable;
          };
      };
    };

    config = lib.modules.mkIf cfg.backends.nushell.enable (lib.modules.mkMerge [
      {
        programs.nushell.enable = true;
      }
      (lib.modules.mkIf cfg.backends.nushell.integrations.direnv.enable
        {
          programs.direnv = {
            enableNushellIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.nushell.integrations.starship.enable
        {
          programs.starship = {
            enableNushellIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.nushell.integrations.yazi.enable
        {
          programs.yazi = {
            enableNushellIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.nushell.integrations.zoxide.enable
        {
          programs.zoxide = {
            enableNushellIntegration = true;
          };
        })
    ]);
  };
}

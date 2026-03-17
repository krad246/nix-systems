{
  flake.modules.homeManager.diff = {
    config,
    lib,
    ...
  }: let
    cfg = config.shell.programs.diff.backends.delta;
  in {
    options.shell.programs.diff.backends.delta.integrations.lazygit.enable =
      lib.options.mkEnableOption "Whether to enable `delta` integration for `lazygit`."
      // {
        default = cfg.integrations.git.enable;
      };

    config.programs.lazygit.settings.git.pagers = lib.modules.mkIf cfg.integrations.lazygit.enable [
      {
        pager =
          lib.strings.concatStringsSep " "
          (lib.toList (lib.meta.getExe cfg.package)
            ++ lib.toList (lib.cli.toGNUCommandLine {} {
              no-gitconfig = true;
              paging = "never";
            }));
      }
    ];
  };
}

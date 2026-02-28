{
  flake.modules.homeManager.fzf = {
    config,
    lib,
    ...
  }: {
    programs.fzf.historyWidgetOptions =
      config.programs.fzf.defaultOptions
      ++ (lib.cli.toGNUCommandLine {} {
        scheme = "history";
      });
  };
}

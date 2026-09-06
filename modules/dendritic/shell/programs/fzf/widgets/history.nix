{lib, ...}: {
  flake.modules.homeManager.fzf = {config, ...}: {
    programs.fzf.historyWidgetOptions =
      config.programs.fzf.defaultOptions
      ++ (lib.cli.toGNUCommandLine {} {
        scheme = "history";
      });
  };
}

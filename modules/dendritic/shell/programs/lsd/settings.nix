{
  flake.modules.homeManager.lsd = {
    programs.lsd.settings = {
      hyperlink = "auto";
    };

    # home.shellAliases.l = lib.meta.getExe config.programs.lsd.package;
  };
}

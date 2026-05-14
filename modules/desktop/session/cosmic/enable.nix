{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.session.cosmic.enable =
      lib.options.mkEnableOption "COSMIC desktop settings dispatcher";
  };
}

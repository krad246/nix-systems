{
  flake.modules.darwin.zoom = {
    appStore.applications.zoom."homebrew.casks" = {
      install = ["zoom"];
    };
  };
}

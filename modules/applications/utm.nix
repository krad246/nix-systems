{
  flake.modules.darwin.utm = {
    appStore.applications.utm."homebrew.casks" = {
      install = [
        "crystalfetch"
        "utm"
      ];
    };
  };
}

{
  flake.modules.darwin.signal = {
    appStore.applications.signal."homebrew.casks" = {
      install = ["signal"];
    };
  };
}

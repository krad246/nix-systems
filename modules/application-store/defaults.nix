{self, ...}: {
  flake.modules.darwin.app-stores = {
    imports = with self.modules.darwin; [
      app-store
      app-store-homebrew-cask
      app-store-mas
      homebrew
    ];
  };
}

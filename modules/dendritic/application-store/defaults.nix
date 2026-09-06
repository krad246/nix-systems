{self, ...}: {
  flake.modules.darwin.app-stores = {
    imports = with self.modules.darwin; [
      app-store
      app-store-tool-homebrew-casks
      app-store-tool-mas-apps
      app-store-tool-nix-packages
      homebrew
    ];
  };
}

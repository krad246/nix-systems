{self, ...}: {
  imports = with self.darwinModules; [
    base-configuration
  ];

  nixpkgs.overlays = [self.overlays.default];
}

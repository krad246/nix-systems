{self, ...}: {
  nixpkgs.overlays = [
    self.overlays.lib
    self.overlays.default
  ];
}

{self, ...}: {
  nixpkgs.overlays = [
    self.overlays.default
  ];
}

{self, ...}: {
  nixpkgs.overlays = [
    self.overlays.default
    self.overlays.unstable
  ];
}

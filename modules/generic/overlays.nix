{self, ...}: {
  nixpkgs.overlays = [
    (_final: prev: {lib = prev.lib.extend self.overlays.lib;})
    self.overlays.krad246
    self.overlays.unstable
  ];
}

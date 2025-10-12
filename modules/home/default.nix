{self, ...}: {
  imports = with self.homeModules; [base-home];

  nixpkgs.overlays = [self.overlays.default];
}

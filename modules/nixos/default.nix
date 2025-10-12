{self, ...}: {
  imports = with self.nixosModules; [base-configuration];

  nixpkgs.overlays = [self.overlays.default];
}

{self, ...}: {
  imports =
    [./qcow.nix] ++ [self.nixosModules.efiboot];

  disko.enableConfig = false;
}

{self, ...}: {
  imports =
    [./raw.nix] ++ [self.nixosModules.efiboot];

  disko.enableConfig = false;
}

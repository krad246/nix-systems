{
  self,
  pkgs,
  ...
}: {
  imports =
    [./iso.nix]
    ++ [self.nixosModules.efiboot];

  environment.systemPackages = with pkgs; [
    calamares-nixos
    calamares-nixos-extensions
  ];

  disko.enableConfig = false;
}

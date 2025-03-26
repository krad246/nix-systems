{self, ...}: {
  imports =
    [
      self.nixosModules.base-configuration
    ]
    ++ [
      ./efiboot.nix
      ./hardware-configuration.nix
      ./remote-access.nix
    ]
    ++ [
      self.diskoConfigurations.fortress-desktop
    ];
}

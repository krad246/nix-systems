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
    ]
    ++ [
      self.modules.generic.dullahan
      self.modules.generic.gremlin
    ];

  krad246.remotes = {
    dullahan = {
      enable = true;
      sshUser = "krad246";
    };
    gremlin = {
      enable = true;
      sshUser = "krad246";
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;
}

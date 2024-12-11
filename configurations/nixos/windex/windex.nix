{self, ...}: {
  imports =
    (with self.nixosModules; [
      nixos
      wsl
    ])
    ++ [
      ./formats.nix
      ./specialisations
      ./users.nix
    ];

  programs.dconf.enable = false;

  # Doesn't make sense on WSL's network stack
  systemd.services.NetworkManager-wait-online.enable = false;
}

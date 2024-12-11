{
  self,
  lib,
  ...
}: {
  imports =
    [self.modules.generic.unfree]
    ++ (with self.nixosModules; [
      flatpak
      gnome-desktop
      nixos
      opengl
      whitesur
    ])
    ++ [
      ./specialisations/efiboot.nix
    ];

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel" "docker" "libvirtd" "NetworkManager" "wireshark"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
  };

  system.stateVersion = lib.trivial.release;
}

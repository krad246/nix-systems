{
  self,
  lib,
  ...
}: {
  imports = with self.nixosModules; [
    gnome-desktop
    nixos
    whitesur
  ];

  services.flatpak.enable = lib.modules.mkDefault false;

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel" "docker" "libvirtd" "NetworkManager" "wireshark"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
    openssh.authorizedKeys = {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzCjoarVDF5bnWX3SBciYyaiMzGnzTF9uefbja5xLB0"
      ];
    };
  };

  system.stateVersion = lib.trivial.release;

  # Default value to shut the flake checker up. Overridden using extendModules.
  nixpkgs.system = lib.modules.mkDefault "x86_64-linux";
}

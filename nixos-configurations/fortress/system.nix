{
  ezModules,
  lib,
  ...
}: {
  imports = with ezModules; [
    bluetooth
    gnome-desktop
    nixos
    pipewire
    system76-scheduler
    whitesur
  ];

  services.flatpak.enable = lib.mkDefault false;

  boot.initrd.systemd.enable = true;
  system.etc.overlay = {
    enable = true;
    mutable = true;
  };

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel"] ++ ["docker" "libvirtd"] ++ ["NetworkManager"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
  };

  system.stateVersion = lib.trivial.release;
}

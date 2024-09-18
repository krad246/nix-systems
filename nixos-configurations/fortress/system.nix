{
  ezModules,
  lib,
  ...
}: {
  imports = with ezModules; [
    amdgpu
    bluetooth
    gnome-desktop
    nixos
    opengl
    pipewire
    system76-scheduler
    whitesur
  ];

  services.flatpak.enable = lib.mkDefault false;

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel"] ++ ["docker" "libvirtd"] ++ ["NetworkManager"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
  };

  system.stateVersion = lib.trivial.release;
}

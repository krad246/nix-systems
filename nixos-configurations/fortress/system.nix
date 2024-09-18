{
  ezModules,
  lib,
  ...
}:
{
  imports = with ezModules; [
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

  services.openssh.enable = true;
  system.stateVersion = lib.trivial.release;
}
// lib.attrsets.optionalAttrs (!lib.trivial.inPureEvalMode) {
  services.flatpak.enable = true;
}

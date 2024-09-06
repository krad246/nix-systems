{
  inputs,
  ezModules,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ (with ezModules; [
      gnome-desktop
      nixos
    ]);

  services.flatpak.enable = lib.mkDefault false;

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel"] ++ ["docker" "libvirtd"] ++ ["NetworkManager"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
  };

  services.displayManager.autoLogin = lib.mkDefault {
    enable = true;
    user = "krad246";
  };

  system.stateVersion = lib.trivial.release;
}

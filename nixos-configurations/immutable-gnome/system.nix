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
      flatpak
      gnome-desktop
      libvirtd
      nixos
      pam-u2f
    ]);

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi";
    extraGroups = ["NetworkManager" "wheel" "libvirtd"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
  };

  services.displayManager.autoLogin = lib.mkDefault {
    enable = true;
    user = "krad246";
  };

  system.stateVersion = lib.trivial.release;
}

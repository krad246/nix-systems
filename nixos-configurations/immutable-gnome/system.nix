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
      kdeconnect
      libvirtd
      nixos
      pam-u2f
      pipewire
    ]);

  # Default settings are simple EFI system on tmpfs
  boot.loader.grub.device = lib.mkDefault "nodev";
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults"];
  };

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi";
    extraGroups = ["NetworkManager" "wheel" "libvirtd"];
    initialHashedPassword = "";
  };

  services.xserver.displayManager.autoLogin = lib.mkDefault {
    enable = true;
    user = "krad246";
  };

  system.stateVersion = lib.trivial.release;
}

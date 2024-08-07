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
      steam
    ]);

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi";
    extraGroups = ["NetworkManager" "wheel" "libvirtd"];
    initialHashedPassword = "";
  };

  services.displayManager.autoLogin = lib.mkDefault {
    enable = true;
    user = "krad246";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.trivial.release;
}

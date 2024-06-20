{
  inputs,
  ezModules,
  lib,
  ...
}: let
  nixosModules = ezModules;
  inherit (inputs) nixos-hardware;
in {
  imports =
    (with nixosModules;
      [efiboot nixos flake-registry impermanence]
      ++ [gnome-desktop nerdfonts]
      ++ [pipewire pam-u2f kdeconnect steam]
      ++ [docker cachix nix-ld libvirtd flatpak])
    ++ (with nixos-hardware.nixosModules; [
      common-cpu-amd
      common-gpu-amd
      common-pc
      common-pc-ssd
    ]);

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi";
    extraGroups = ["NetworkManager" "wheel" "libvirtd"];
    initialHashedPassword = "$y$j9T$oZ2NvBDMhd93Rg4bK7eYf/$TwJuUcU8xdN4SzNfYaY5xA15B.tbHQkhdTmJyF80zzB";
  };

  nix.settings.trusted-users = ["krad246"];

  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = lib.trivial.release;
}

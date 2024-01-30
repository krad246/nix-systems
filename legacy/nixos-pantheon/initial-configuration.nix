# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  imports = [
    ../../nixos-modules/efiboot.nix
    ../../nixos-modules/nerdfonts.nix
    ../../nixos-modules/nixos
    ../../nixos-modules/gnome-desktop.nix
    ../../nixos-modules/pipewire.nix
  ];

  networking.hostName = "nixos-pantheon"; # Define your hostname.

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi";
    extraGroups = ["NetworkManager" "wheel"];
    initialHashedPassword = "";
  };
}

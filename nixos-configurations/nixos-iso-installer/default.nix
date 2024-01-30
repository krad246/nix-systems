{
  ezModules,
  lib,
  ...
}: {
  imports = [ezModules.nixos-cli ezModules.gnome-iso];
  networking.hostName = "nixos-iso-installer";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

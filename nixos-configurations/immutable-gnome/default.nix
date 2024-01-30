{
  lib,
  pkgs,
  ...
}: {
  imports = [./immutable-gnome.nix ./platform.nix ./filesystems.nix];
  networking.hostName = "immutable-gnome";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = with pkgs; [
    whitesur-gtk-theme
    whitesur-icon-theme
    whitesur-cursors
  ];
}

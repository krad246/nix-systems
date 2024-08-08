{lib, ...}: {
  imports = [./simple.nix];

  disko.enableConfig = lib.mkDefault true;
}

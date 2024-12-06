{lib, ...}: {
  imports = [./virtualbox.nix];

  documentation.nixos.enable = lib.modules.mkForce false;
}

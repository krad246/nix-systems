{lib, ...}: {
  imports = [./virtualbox.nix];
  security.sudo.wheelNeedsPassword = lib.modules.mkForce false;
}

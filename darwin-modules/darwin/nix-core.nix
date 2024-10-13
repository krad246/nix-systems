{lib, ...}: {
  imports = [../../common/nix-core.nix];

  nix.useDaemon = lib.mkForce true;
  services.nix-daemon.enable = lib.mkForce true;
  system.stateVersion = 4;
}

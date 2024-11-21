{
  self,
  inputs,
  lib,
  ...
}: {
  imports =
    (with self.modules.generic; [
      agenix
      flake-registry
      hm-compat
      nix-core
      unfree
    ])
    ++ (with self.darwinModules; [
      docker-desktop
      homebrew
      linux-builder
      mac-app-util
      plist-settings
      system-packages
    ])
    ++ (with inputs; [
      home-manager.darwinModules.home-manager
      agenix.darwinModules.age
    ]);

  nix.settings = {
    auto-optimise-store = false;
    sandbox = false;
  };

  nix.useDaemon = lib.mkForce true;
  services.nix-daemon.enable = lib.mkForce true;
  system.stateVersion = 4;
}

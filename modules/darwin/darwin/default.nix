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
    ++ [
      ./homebrew.nix
      ./linux-builder.nix
      ./mac-app-util.nix
      ./plist-settings.nix
      ./system-packages.nix
    ]
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

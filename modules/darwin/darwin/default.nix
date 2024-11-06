{
  inputs,
  self,
  lib,
  ...
}: let
  inherit (inputs) home-manager;
  inherit (inputs) agenix;
in {
  imports =
    [self.modules.generic.unfree self.modules.generic.agenix self.modules.generic.nix-core self.modules.generic.flake-registry]
    ++ [
      ./homebrew.nix
      ./linux-builder.nix
      ./mac-app-util.nix
      ./plist-settings.nix
      ./system-packages.nix
    ]
    ++ [
      home-manager.darwinModules.home-manager
      agenix.darwinModules.age
    ]
    ++ [
      self.darwinModules.docker-desktop
    ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {
    };
    sharedModules = [];
    verbose = false;
  };

  nix.settings = {
    auto-optimise-store = false;
    sandbox = false;
  };

  nix.useDaemon = lib.mkForce true;
  services.nix-daemon.enable = lib.mkForce true;
  system.stateVersion = 4;
}

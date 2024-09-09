{inputs, ...}: let
  inherit (inputs) home-manager;
in {
  imports =
    [
      ./agenix.nix
      ./flake-registry.nix
      ./homebrew
      ./linux-builder.nix
      ./mac-app-util.nix
      ./nix-core.nix
      ./system-packages.nix
      ./system-settings.nix
    ]
    ++ [
      home-manager.darwinModules.home-manager
    ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {
    };
    sharedModules = [];
    verbose = true;
  };
}

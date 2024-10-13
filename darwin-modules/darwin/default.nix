{inputs, ...}: let
  inherit (inputs) home-manager;
in {
  imports =
    [../../common/unfree.nix]
    ++ [
      ./agenix.nix
      ./homebrew.nix
      ./linux-builder.nix
      ./mac-app-util.nix
      ./nix-core.nix
      ./plist-settings.nix
      ./system-packages.nix
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
    verbose = false;
  };
}

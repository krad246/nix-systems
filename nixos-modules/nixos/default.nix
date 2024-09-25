{inputs, ...}: let
  inherit (inputs) home-manager;
in {
  imports =
    [
      ./binfmt.nix
      ./ccache-stdenv.nix
      ./default-users.nix
      ./environment.nix
      ./flake-registry.nix
      ./kernel.nix
      ./nix-daemon.nix
      ./nix-ld.nix
      ./packages.nix
      ./unfree.nix
      ./zram.nix
    ]
    ++ [
      home-manager.nixosModules.home-manager
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

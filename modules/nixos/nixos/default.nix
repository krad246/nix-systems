{
  self,
  inputs,
  ...
}: let
  inherit (inputs) home-manager;
in {
  imports =
    [
      self.nixosModules.ccache-stdenv
      self.nixosModules.darling
    ]
    ++ [
      ./aarch64-binfmt.nix
      ./default-users.nix
      ./environment.nix
      ./kernel.nix
      ./nix-daemon.nix
      ./nix-ld.nix
      ./packages.nix
      ./unfree.nix
      ./zram.nix
    ]
    ++ [
      home-manager.nixosModules.home-manager
    ]
    ++ [self.modules.generic.flake-registry];

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

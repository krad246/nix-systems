{inputs, ...}: let
  inherit (inputs) home-manager;
in {
  imports = [home-manager.nixosModules.home-manager];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    verbose = true;
    sharedModules = [];
  };
}

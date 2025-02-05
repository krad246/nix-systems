{inputs, ...}: let
  inherit (inputs) home-manager;
in {
  imports = [home-manager.darwinModules.home-manager];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    verbose = false;
  };
}

{
  inputs,
  self,
  ...
}: let
  inherit (inputs) home-manager;
in {
  imports = [home-manager.darwinModules.home-manager];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = self.dirtyRev or self.rev or "bak";
    verbose = false;
  };
}

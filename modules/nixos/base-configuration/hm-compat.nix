{
  inputs,
  self,
  ...
}: let
  inherit (inputs) home-manager;
in {
  imports = [home-manager.nixosModules.home-manager];

  home-manager = {
    useUserPackages = true;
    # useGlobalPkgs = true;
    backupFileExtension = self.rev or self.dirtyRev or "bak";
    verbose = true;
    sharedModules = [];
  };
}

{
  inputs,
  self,
  ...
}: {
  flake.modules = let
    impl = {
      home-manager = {
        useUserPackages = true;
        # useGlobalPkgs = true;
        backupFileExtension = self.rev or self.dirtyRev or "bak";
        verbose = true;

        # TODO: make this apply on an individual user basis
        sharedModules = [
          self.modules.homeManager.home-manager
        ];
      };
    };
  in {
    darwin.home-manager = {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        impl
      ];
    };

    nixos.home-manager = {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        impl
      ];
    };

    homeManager.home-manager = {
      programs.home-manager.enable = true;
    };
  };
}

{
  self,
  self',
  inputs',
  config,
  pkgs,
  ...
}: {
  devShells =
    {
      default = import ./devshell.nix {inherit self' config pkgs;};
    }
    // {
      chrootenv = self'.packages.devshell-chrootenv.env;
      bwrapenv = self'.packages.devshell-bwrapenv.env;
    };

  just-flake.features = import ./just-flake.nix {
    inherit self self' inputs' pkgs;
  };
}

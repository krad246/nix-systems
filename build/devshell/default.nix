{
  self,
  self',
  inputs',
  config,
  pkgs,
  ...
}: {
  devShells.default = import ./devshell.nix {inherit self' config pkgs;};
  just-flake.features = import ./just-flake.nix {
    inherit self self' inputs' pkgs;
  };
}

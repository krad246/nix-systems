{
  pkgs,
  inputs',
  ...
}: {
  apps = {
    bootstrap = import ./bootstrap.nix;
    devour-flake = import ./devour-flake.nix {inherit pkgs inputs';};
  };
}

# outer / 'flake' scope
{
  inputs,
  self,
  ...
}: {
  perSystem = {
    lib,
    pkgs,
    inputs',
    self',
    ...
  }: {
    apps = {
      bootstrap = import ./bootstrap.nix {inherit pkgs inputs';};
      devour-flake = import ./devour-flake.nix {inherit inputs self lib pkgs self';};
    };
  };
}

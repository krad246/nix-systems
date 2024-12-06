# outer / 'flake' scope
{
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    apps = {
      bootstrap = import ./bootstrap.nix {inherit inputs' pkgs;};
      devour-flake = import ./devour-flake.nix {inherit inputs self pkgs;};
    };
  };
}

# outer / 'flake' scope
{
  nixArgs,
  self,
  inputs,
  ...
}: {
  perSystem = {
    inputs',
    lib,
    pkgs,
    ...
  }: {
    apps = {
      bootstrap = import ./bootstrap.nix {inherit inputs' lib pkgs;};
      devour-flake = import ./devour-flake.nix {inherit nixArgs self inputs lib pkgs;};
    };
  };
}

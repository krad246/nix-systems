# outer / 'flake' scope
_: {
  perSystem = {
    lib,
    pkgs,
    inputs',
    self',
    ...
  }: {
    apps = {
      bootstrap = import ./bootstrap.nix {inherit pkgs inputs';};
      devour-flake = import ./devour-flake.nix {inherit lib self';};
    };
  };
}

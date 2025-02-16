# outer / 'flake' scope
_: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    apps = {
      bootstrap = import ./bootstrap.nix {inherit pkgs inputs';};
    };
  };
}

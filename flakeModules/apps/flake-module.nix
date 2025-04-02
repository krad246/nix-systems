# outer / 'flake' scope
_: {
  perSystem = ctx @ {
    config,
    lib,
    pkgs,
    ...
  }: {
    apps = {
      bootstrap = import ./bootstrap.nix {
        inherit (ctx) config lib pkgs;
      };
    };
  };
}

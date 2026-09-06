{self, ...}: {
  perSystem = {
    inputs',
    config,
    ...
  }: {
    _module.args.pkgs = config.legacyPackages;

    legacyPackages = inputs'.nixpkgs.legacyPackages.extend self.overlays.unstable;
  };
}

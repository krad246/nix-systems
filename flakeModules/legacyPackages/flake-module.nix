{
  inputs,
  self,
  ...
}: {
  perSystem = {system, ...}: rec {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      overlays = [self.overlays.default];
      config = {};
    };
  };
}

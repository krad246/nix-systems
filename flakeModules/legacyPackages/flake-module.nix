{
  inputs,
  self,
  ...
}: {
  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      overlays = [
        self.overlays.default
        self.overlays.unstable
      ];
      config = {};
    };
  };
}

{
  withSystem,
  self,
  ...
}: {
  flake-file.inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  flake = {
    modules = {
      homeManager.nixpkgs-unstable = {
        nixpkgs.overlays = [self.overlays.unstable];
      };

      nixos.nixpkgs-unstable = {
        nixpkgs.overlays = [self.overlays.unstable];
      };
    };

    overlays = {
      unstable = _: prev: {
        unstable = withSystem prev.stdenv.hostPlatform.system (ctx: ctx.inputs'.nixpkgs-unstable.legacyPackages);
      };
    };
  };
}

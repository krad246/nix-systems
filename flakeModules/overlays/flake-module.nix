# outer / 'flake' scope
{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  flake = rec {
    overlays.lib = import ./lib;

    lib = inputs.nixpkgs.lib.extend overlays.lib;
  };

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    overlayAttrs = {
      lib = pkgs.lib.extend self.overlays.lib;
      krad246 = pkgs.lib.customisation.makeScope pkgs.newScope (_: {
        inherit (config.packages) term-fonts;
      });
    };
  };
}

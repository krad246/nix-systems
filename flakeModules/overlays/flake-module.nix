# outer / 'flake' scope
{inputs, ...}: {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    overlayAttrs = {
      krad246 = pkgs.lib.customisation.makeScope pkgs.newScope (_: {
        inherit (config.packages) term-fonts;
      });
    };
  };
}

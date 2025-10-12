# outer / 'flake' scope
{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    overlayAttrs = {
      inherit (self) lib;
      krad246 = pkgs.lib.customisation.makeScope pkgs.newScope (_: {
        inherit (config.packages) term-fonts;
      });
    };
  };
}

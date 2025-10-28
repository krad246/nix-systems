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
    lib = inputs.nixpkgs.lib.extend overlays.lib;

    overlays = {
      lib = import ./lib;

      unstable = _final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev) config overlays system;
        };
      };
    };
  };

  perSystem = {
    inputs',
    config,
    pkgs,
    ...
  }: {
    overlayAttrs = {
      lib = pkgs.lib.extend self.overlays.lib;
      krad246 = {
        agenix = inputs'.agenix.packages.default;
        inherit (config.packages) disko-install;
        firefox-addons = {
          inherit (inputs'.nur.legacyPackages.repos.rycee.firefox-addons) bitwarden ghostery multi-account-containers vimium;
        };
        inherit (config) formatter;
        inherit (config.packages) term-fonts;
      };
    };
  };
}

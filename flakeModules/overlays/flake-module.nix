# outer / 'flake' scope
{
  withSystem,
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

      krad246 = _final: prev:
        withSystem prev.stdenv.hostPlatform.system (
          {
            inputs',
            config,
            ...
          }: {
            krad246 = {
              agenix = inputs'.agenix.packages.default;

              inherit (config.packages) disko-install;

              firefox-addons = {
                inherit (inputs'.nur.legacyPackages.repos.rycee.firefox-addons) bitwarden ghostery multi-account-containers vimium;
              };

              inherit (config.packages) term-fonts;
            };
          }
        );

      flake = _final: prev:
        withSystem prev.stdenv.hostPlatform.system (
          {config, ...}: {
            flake = {
              flake-root = config.flake-root.package;
              inherit (config) formatter;
            };
          }
        );
    };
  };

  perSystem = {pkgs, ...}: {
    overlayAttrs = {
      lib = pkgs.lib.extend self.overlays.lib;
      flake = pkgs.extend self.overlays.flake;
      krad246 = pkgs.extend self.overlays.krad246;
      unstable = pkgs.extend self.overlays.unstable;
    };
  };
}

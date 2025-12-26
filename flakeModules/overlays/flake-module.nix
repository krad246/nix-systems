# outer / 'flake' scope
{
  withSystem,
  inputs,
  self,
  lib,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];

  perSystem = {
    pkgs,
    final,
    ...
  }: {
    overlayAttrs = self.overlays.combined final pkgs;
  };

  flake = let
    ext = import ./lib;
  in {
    lib = lib.extend ext;

    overlays = {
      combined = lib.fixedPoints.composeManyExtensions ([
          self.overlays.unstable
        ]
        ++ [
          self.overlays.flake
          self.overlays.krad246
        ]);

      # This flake's outputs
      flake = _final: prev:
        withSystem prev.stdenv.hostPlatform.system (
          {config, ...}: {
            flake = {
              flake-root = config.flake-root.package;
              inherit (config) formatter;
            };
          }
        );

      # krad246 packages and custom behaviors
      krad246 = _final: prev:
        withSystem prev.stdenv.hostPlatform.system (
          {
            inputs',
            config,
            ...
          }: {
            lib = prev.lib.extend ext;

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

      # Unstable package set
      unstable = _final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev) config overlays system;
        };
      };
    };
  };
}

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

  flake = let
    ext = import ./lib;
  in {
    lib = inputs.nixpkgs.lib.extend ext;

    overlays = {
      # Unstable package set
      unstable = _final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev) config overlays system;
        };
      };

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
    };
  };

  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    overlayAttrs = let
      inherit (lib) fixedPoints;
      pkgs' = pkgs.extend (fixedPoints.composeManyExtensions [
        self.overlays.flake
        self.overlays.krad246
        self.overlays.unstable
      ]);
    in {
      inherit (pkgs') flake;
      inherit (pkgs') lib;
      inherit (pkgs') krad246;
      inherit (pkgs') unstable;
    };
  };
}

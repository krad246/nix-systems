inputs @ {flake-parts, ...}:
flake-parts.lib.mkFlake
# Environment
{
  inherit inputs;
}
({self, ...}: let
  apps = ./flakeModules/apps;
  checks = ./flakeModules/checks;
  devShell = ./flakeModules/devShell;
  ezConfigs = ./flakeModules/ezConfigs; # ties system and home configurations together
  herculesCI = ./flakeModules/herculesCI;
  legacyPackages = ./flakeModules/legacyPackages;
  overlays = ./flakeModules/overlays;
  packages = ./flakeModules/packages;

  toplevel = {
    imports = [
      apps
      checks
      devShell
      ezConfigs
      herculesCI
      legacyPackages
      overlays
      packages
    ];
  };
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports =
    [
      flake-parts.flakeModules.flakeModules
      flake-parts.flakeModules.modules
    ]
    ++ [
      toplevel
    ]
    ++ [
      flake-parts.flakeModules.partitions
    ];

  flake = rec {
    flakeModules = {
      default = toplevel;

      inherit apps;
      inherit checks;
      inherit devShell;
      inherit ezConfigs;
      inherit herculesCI;
      inherit legacyPackages;
      inherit overlays;
      inherit packages;
    };

    # use these for the options namespaces of system / home configurations
    modules = {
      flake = flakeModules; # alias output name

      # ezConfigs does the heavy lifting of figuring these out for us

      nixos = self.nixosModules;
      darwin = self.darwinModules;
      home = self.homeModules;

      # can be used in all of the above contexts
      generic = let
        inherit (self.lib) krad246;
        paths = krad246.fileset.filterExt "nix" ./modules/generic;
      in
        krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path (import path));
    };
  };

  systems = import inputs.systems;
})

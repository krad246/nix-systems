{
  inputs,
  self,
  lib,
  ...
}: let
  apps = ./apps;
  checks = ./checks;
  devShell = ./devShell;
  ezConfigs = ./ezConfigs; # ties system and home configurations together
  herculesCI = ./herculesCI;
  packages = ./packages;
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports =
    (with inputs; [
      flake-parts.flakeModules.modules
      flake-parts.flakeModules.flakeModules
    ])
    ++ [
      apps
      checks
      devShell
      ezConfigs
      herculesCI
      packages
    ];

  flake = rec {
    # use these in building other flakes
    flakeModules = {
      default = ./.;

      inherit apps;
      inherit checks;
      inherit devShell;
      inherit ezConfigs;
      inherit herculesCI;
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
        inherit (lib) krad246;
        paths = krad246.fileset.filterExt "nix" ../modules/generic;
      in
        krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path (import path));
    };
  };
}

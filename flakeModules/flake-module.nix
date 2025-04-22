args @ {
  inputs,
  self,
  lib,
  ...
}: let
  apps = import ./apps args;
  checks = import ./checks args;
  devShell = import ./devShell args;
  ezConfigs = import ./ezConfigs args; # ties system and home configurations together
  herculesCI = import ./herculesCI args;
  packages = import ./packages args;
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports =
    (with inputs; [
      flake-parts.flakeModules.modules
      flake-parts.flakeModules.flakeModules
    ])
    ++ [
      apps.flakeModule # adds to flake apps
      checks.flakeModule # adds to flake checks
      devShell.flakeModule # adds to flake devShells
      ezConfigs.flakeModule # adds to nixosConfigurations, etc.
      herculesCI.flakeModule
      packages.flakeModule # adds to packages
    ];

  flake = rec {
    # use these in building other flakes
    flakeModules = {
      default = ./.;

      apps = apps.flakeModule;
      checks = checks.flakeModule;
      devShells = devShell.flakeModule;
      ezConfigs = ezConfigs.flakeModule;
      herculesCI = herculesCI.flakeModule;
      packages = packages.flakeModule;
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

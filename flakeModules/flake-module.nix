args @ {
  inputs,
  self,
  lib,
  ...
}: let
  apps = import ./apps args;
  devShell = import ./devShell args;
  ez-configs = import ./ez-configs args; # ties system and home configurations together
  hercules-ci = import ./hercules-ci args;
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
      devShell.flakeModule # adds to flake devShellsA
      ez-configs.flakeModule # adds to nixosConfigurations, etc.
      hercules-ci.flakeModule
      packages.flakeModule # adds to packages
    ];

  flake = rec {
    # use these in building other flakes
    flakeModules = {
      default = ./.;

      apps = apps.flakeModule;
      devShells = devShell.flakeModule;
      ez-configs = ez-configs.flakeModule;
      packages = packages.flakeModule;
    };

    # use these for the options namespaces of system / home configurations
    modules = {
      flake = flakeModules; # alias output name

      # ez-configs does the heavy lifting of figuring these out for us

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

# outer / 'flake' scope
{
  withSystem,
  importApply,
  self,
  lib,
  inputs,
  ...
}: let
  inherit (lib) attrsets fileset strings;

  nixArgs = lib: let
    inherit (lib) attrsets strings;
  in {
    option = attrsets.mapAttrsToList (name: value: strings.concatStringsSep " " [name value]) {
      experimental-features = ''"nix-command flakes"'';
      builders-use-substitutes = "true";
      preallocate-contents = "true";
      accept-flake-config = "true";
      inputs-from = self;
      keep-going = "true";
      show-trace = "true";
    };
  };

  # standard outputs
  apps = import ./apps {inherit importApply nixArgs self inputs;};
  devShells = import ./devshell {inherit importApply nixArgs self inputs;};
  packages = import ./packages {inherit importApply self;};

  # Module that streamlines tying together system and home configurations.
  ez-configs = import ./ez-configs {inherit importApply self inputs;};

  # bla
  overlays = import ./overlays {inherit withSystem importApply self inputs lib;};
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports = [
    apps.flakeModule
    devShells.flakeModule
    ez-configs.flakeModule
    packages.flakeModule
    overlays.flakeModule
  ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      default = ./.;

      apps = apps.flakeModule;
      devShells = devShells.flakeModule;
      ez-configs = ez-configs.flakeModule;
      packages = packages.flakeModule;
      overlays = overlays.flakeModule;
    };

    modules = {
      flake = flakeModules;

      # ez-configs does the heavy lifting of figuring these out for us

      nixos = self.nixosModules;
      darwin = self.darwinModules;
      home = self.homeModules;

      # we follow the same methodology to pull in generic, use-anywhere modules below...

      generic = let
        # get all nix files in generic
        filterNix = path: fileset.fileFilter (file: file.hasExt "nix") path;
        hits = filterNix ../generic;

        # for each file, make a key-value pair where the key is the basename of the file
        # and the value is a trivial attrset / module file that needs to be exported as a callable
        toModule = path: let
          moduleName = strings.removeSuffix ".nix" (builtins.baseNameOf path);
          body = import path;
        in
          attrsets.nameValuePair moduleName body;

        importList = builtins.map toModule (fileset.toList hits);
        modules = builtins.listToAttrs importList;
      in
        modules;
    };
  };

  perSystem = {pkgs, ...}: {
    checks = {
      hello = pkgs.testers.runNixOSTest {
        name = "hello";
        nodes.machine = {pkgs, ...}: {
          environment.systemPackages = [pkgs.hello];
        };
        testScript = ''
          machine.succeed("hello")
        '';
      };
    };
  };
}

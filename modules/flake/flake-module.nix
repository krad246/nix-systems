args @ {
  withSystem,
  inputs,
  self,
  lib,
  ...
}: let
  # hijacking specialArgs convention for both importApply as well as passing directly to ez-configs
  specialArgs = {
    inherit withSystem;
    inherit inputs self;

    # my own small helper library of sorts
    krad246 = rec {
      attrsets = {
        genAttrs' = keys: f: builtins.listToAttrs (builtins.map f keys);

        stemValuePair = key: value: lib.attrsets.nameValuePair (strings.stem key) value;
      };

      cli = {
        toGNUCommandLineShell = bin: args: let
          formatted = [bin] ++ (lib.cli.toGNUCommandLine {} args);
        in
          lib.strings.concatStringsSep " " formatted;
      };

      fileset = {
        filterExt = ext: dir: lib.fileset.toList (lib.fileset.fileFilter (file: file.hasExt ext) dir);
      };

      strings = {
        stem = path: lib.strings.nameFromURL (builtins.baseNameOf path) ".";
      };
    };

    # shared arguments for nix binaries called
    nixArgs = let
      inherit (lib) cli;
    in
      cli.toGNUCommandLine {} {
        option = [
          "inputs-from ${self}"
          "experimental-features 'nix-command flakes'"
          "keep-going true"
          "show-trace true"
          "accept-flake-config true"
          "builders-use-substitutes true"
          "preallocate-contents true"
          "allow-import-from-derivation true"
        ];

        verbose = true;
        # print-build-logs = true;
      };
  };

  forwarded = args // {inherit specialArgs;};

  # flake outputs

  apps = import ./apps forwarded;
  devShells = import ./devshell forwarded;
  ez-configs = import ./ez-configs forwarded; # ties system and home configurations together
  packages = import ./packages forwarded;
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports = [
    apps.flakeModule # adds to flake apps
    devShells.flakeModule # adds to flake devShells
    ez-configs.flakeModule # adds to nixosConfigurations, etc.
    packages.flakeModule # adds to packages
  ];

  flake = rec {
    # use these in building other flakes
    flakeModules = {
      default = ./.;

      apps = apps.flakeModule;
      devShells = devShells.flakeModule;
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
        inherit (specialArgs) krad246;
        paths = krad246.fileset.filterExt "nix" ../generic;
      in
        krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path (import path));
    };

    checks = {
      aarch64-linux = withSystem "aarch64-linux" ({pkgs, ...}: {
        hello = pkgs.testers.runNixOSTest {
          name = "hello";
          nodes.machine = {pkgs, ...}: {
            environment.systemPackages = [pkgs.hello];
          };
          testScript = ''
            machine.succeed("hello")
          '';
        };
      });
    };
  };
}

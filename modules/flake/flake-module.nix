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
    krad246 = rec {
      attrsets = {
        genAttrs' = keys: f: builtins.listToAttrs (builtins.map f keys);

        stemValuePair = key: value: lib.attrsets.nameValuePair (strings.stem key) value;
      };

      cli = {
        toGNUCommandLineShell = bin: args: let
          formatted = lib.cli.toGNUCommandLine {} args;
        in ''
          ${bin} ${lib.strings.concatStringsSep " " formatted}
        '';
      };

      fileset = {
        filterExt = ext: dir: lib.fileset.toList (lib.fileset.fileFilter (file: file.hasExt ext) dir);
      };

      strings = {
        stem = path: lib.strings.nameFromURL (builtins.baseNameOf path) ".";
      };
    };
  };

  # standard outputs
  apps = import ./apps args;
  devShells = import ./devshell args;
  packages = import ./packages (args // {inherit specialArgs;});

  # Module that streamlines tying together system and home configurations.
  ez-configs = import ./ez-configs (args // {inherit specialArgs;});
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports = [
    apps.flakeModule
    devShells.flakeModule
    ez-configs.flakeModule
    packages.flakeModule
  ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      default = ./.;

      apps = apps.flakeModule;
      devShells = devShells.flakeModule;
      ez-configs = ez-configs.flakeModule;
      packages = packages.flakeModule;
    };

    modules = {
      flake = flakeModules;

      # ez-configs does the heavy lifting of figuring these out for us

      nixos = self.nixosModules;
      darwin = self.darwinModules;
      home = self.homeModules;

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

{
  withSystem,
  importApply,
  inputs,
  self,
  specialArgs,
  ...
}: let
  # Sets up container image packages, custom devShell derivation within the container
  # VSCode *is* supported!
  containers = import ./containers {inherit importApply self;};
  nixos-generators = import ./nixos-generators {inherit withSystem importApply inputs self specialArgs;};
  disko-config = import ./disko {inherit importApply;};
in {
  imports = [disko-config.flakeModule nixos-generators.flakeModule];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      containers = containers.flakeModule;
      nixos-generators = nixos-generators.flakeModule;
      disko-config = disko-config.flakeModule;
    };

    modules.flake = flakeModules;

    packages = {
      aarch64-darwin = {
        "krad246@nixbook-pro" = self.homeConfigurations."krad246@nixbook-pro".activationPackage;
        "krad246@dullahan" = self.homeConfigurations."krad246@dullahan".activationPackage;
        "krad246@nixbook-air" = self.homeConfigurations."krad246@nixbook-air".activationPackage;
      };

      x86_64-linux = {
        "krad246@fortress" = self.homeConfigurations."krad246@fortress".activationPackage;
        "krad246@windex" = self.homeConfigurations."krad246@windex".activationPackage;
        "keerad@windex" = self.homeConfigurations."keerad@windex".activationPackage;
      };

      aarch64-linux = {
        "krad246@fortress" = let
          extended = self.homeConfigurations."krad246@fortress".extendModules {
            modules = [
              {
                nixpkgs.system = "aarch64-linux";
              }
            ];
          };
        in
          extended.activationPackage;

        "krad246@windex" = let
          extended = self.homeConfigurations."krad246@windex".extendModules {
            modules = [
              {
                nixpkgs.system = "aarch64-linux";
              }
            ];
          };
        in
          extended.activationPackage;

        "keerad@windex" = let
          extended = self.homeConfigurations."keerad@windex".extendModules {
            modules = [
              {
                nixpkgs.system = "aarch64-linux";
              }
            ];
          };
        in
          extended.activationPackage;
      };
    };
  };

  perSystem = {
    config,
    lib,
    pkgs,
    self',
    ...
  }: let
    # Core package list for the host
    targetPkgs = tpkgs:
      with tpkgs;
        [git]
        ++ [direnv nix-direnv]
        ++ [just gnumake]
        ++ [shellcheck nil];

    inputsFrom = [
      config.flake-root.devShell
      config.just-flake.outputs.devShell
      config.treefmt.build.devShell
      config.pre-commit.devShell
    ];
    # equivalent of mkShell inputsFrom
    # append devShell dependencies to nativeBuildInputs
  in {
    packages =
      {
        nix-shell-env = import ./nix-shell-env.nix {
          inherit config pkgs;
          inherit targetPkgs;
          inherit inputsFrom;
          shellHook = ''
            if [[ -f /.dockerenv ]]; then
              # nix-build doesn't play very nice with the sticky bit
              # and /tmp in a docker environment. unsetting it enables
              # the container to manage its tmpfs as it pleases.
              unset TEMP TMPDIR NIX_BUILD_TOP
            else
              :
            fi
          '';
        };

        devour-flake = import ./devour-flake.nix {
          inherit inputs self lib pkgs;
        };
      }
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        disko-install = import ./disko-install.nix {inherit self pkgs;};

        # linux has first class support for namespacing, the backend of docker
        # this means that we have a slightly simpler container interface available
        # with more capabilities on linux environments
        bwrapenv = let
          inputsFrom = [
            self'.devShells.nix-shell
          ];

          # equivalent of mkShell inputsFrom
          # append devShell dependencies to nativeBuildInputs
          nativeBuildInputs = let
            # 1. get all `{build,nativeBuild,...}Inputs` from the elements of `inputs`
            # 2. since that is a list of lists, `flatten` that into a regular list
            # 3. filter out of the result everything that's in `inputsFrom` itself
            # this leaves actual dependencies of the derivations in `inputsFrom`, but never the derivations themselves
            mergeInputs = inputs: name: (lib.subtractLists inputs (lib.flatten (lib.catAttrs name inputs)));
          in
            mergeInputs inputsFrom "nativeBuildInputs";

          bwrap = pkgs.buildFHSEnvBubblewrap {
            name = "bwrapenv";
            inherit nativeBuildInputs;
          };
        in
          bwrap;
      });
  };
}

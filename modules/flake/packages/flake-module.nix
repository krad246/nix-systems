{
  importApply,
  inputs,
  self,
  ...
}: let
  # Sets up container image packages, custom devShell derivation within the container
  # VSCode *is* supported!
  containers = import ./containers {inherit importApply self;};
  nixos-generators = import ./nixos-generators {inherit importApply self;};
in {
  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      containers = containers.flakeModule;
      nixos-generators = nixos-generators.flakeModule;
    };

    modules.flake = flakeModules;
  };

  perSystem = {
    config,
    lib,
    pkgs,
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
    nativeBuildInputs = let
      # 1. get all `{build,nativeBuild,...}Inputs` from the elements of `inputs`
      # 2. since that is a list of lists, `flatten` that into a regular list
      # 3. filter out of the result everything that's in `inputsFrom` itself
      # this leaves actual dependencies of the derivations in `inputsFrom`, but never the derivations themselves
      mergeInputs = inputs: name: (lib.lists.subtractLists inputs (lib.flatten (lib.attrsets.catAttrs name inputs)));
    in
      mergeInputs inputsFrom "nativeBuildInputs";
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
        # containerized / bwrap-ified devshell environment
        devshell-bwrapenv = let
          result = pkgs.buildFHSEnvBubblewrap {
            name = "bwrapenv";
            inherit targetPkgs nativeBuildInputs;
          };
        in
          result;

        disko-install = import ./disko-install.nix {inherit self lib pkgs;};
      });
  };
}

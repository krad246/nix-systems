{
  self,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in {
  packages = let
    # equivalent of mkShell inputsFrom
    # append devShell dependencies to nativeBuildInputs
    nativeBuildInputs = let
      inputsFrom = [
        config.flake-root.devShell
        config.just-flake.outputs.devShell
        config.treefmt.build.devShell
        config.pre-commit.devShell
      ];

      # 1. get all `{build,nativeBuild,...}Inputs` from the elements of `inputs`
      # 2. since that is a list of lists, `flatten` that into a regular list
      # 3. filter out of the result everything that's in `inputsFrom` itself
      # this leaves actual dependencies of the derivations in `inputsFrom`, but never the derivations themselves
      mergeInputs = inputs: name: (lib.subtractLists inputs (lib.flatten (lib.catAttrs name inputs)));
    in
      mergeInputs inputsFrom "nativeBuildInputs";

    # Core package list for the host
    targetPkgs = tpkgs:
      with tpkgs;
        [git]
        ++ [direnv nix-direnv]
        ++ [just gnumake]
        ++ [shellcheck nil];
  in
    (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      disko-install = import ./disko-install.nix {inherit self pkgs;};

      devshell-bwrapenv = pkgs.buildFHSEnvBubblewrap {
        name = "bwrapenv";
        inherit nativeBuildInputs targetPkgs;
      };
    })
    // {
      nix-shell-env = let
        # construct a simple rootfs derivation with the packages
        paths = targetPkgs pkgs;
        fs = pkgs.buildEnv {
          name = "nix-shell";
          inherit paths;
        };
      in
        fs.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ nativeBuildInputs ++ paths;
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
        });
    };
}

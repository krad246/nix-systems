{
  self,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in {
  packages =
    (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      disko-install = import ./disko-install.nix {inherit self pkgs;};
    })
    // (let
      # TODO: must port devShell inputsFrom.
      inputsFrom = [
        config.flake-root.devShell
        config.just-flake.outputs.devShell
        config.treefmt.build.devShell
        config.pre-commit.devShell
      ];

      # 1. get all `{build,nativeBuild,...}Inputs` from the elements of `inputsFrom`
      # 2. since that is a list of lists, `flatten` that into a regular list
      # 3. filter out of the result everything that's in `inputsFrom` itself
      # this leaves actual dependencies of the derivations in `inputsFrom`, but never the derivations themselves
      mergeInputs = name: (lib.subtractLists inputsFrom (lib.flatten (lib.catAttrs name inputsFrom)));

      nativeBuildInputs = mergeInputs "nativeBuildInputs";

      targetPkgs = tpkgs:
        with tpkgs;
          [git]
          ++ [direnv nix-direnv]
          ++ [just gnumake]
          ++ [shellcheck nil];

      profile = ''
        if [[ -f /.dockerenv ]]; then
          # nix-build doesn't play very nice with the sticky bit
          # and /tmp in a docker environment. unsetting it enables
          # the container to manage its tmpfs as it pleases.
          unset TEMP TMPDIR NIX_BUILD_TOP
        else
          :
        fi
      '';
    in
      lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        devshell-bwrapenv = pkgs.buildFHSEnvBubblewrap {
          name = "devshell";
          inherit targetPkgs profile nativeBuildInputs;
        };
        devshell-chrootenv = pkgs.buildFHSEnvChroot {
          name = "devshell";
          inherit targetPkgs profile;
        };
      });
}

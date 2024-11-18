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
    // (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      devshell-bwrapenv = pkgs.buildFHSEnvBubblewrap {
        name = "bwrapenv";

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

        unshareUser = true;
        unshareIpc = true;
        unsharePid = true;
        unshareNet = true;
        unshareUts = true;
        unshareCgroup = true;
        privateTmp = true;
      };
    });
}

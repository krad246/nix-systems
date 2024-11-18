{
  self,
  self',
  inputs',
  config,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in {
  devShells =
    {
      # prefer an interpreter-level venv by default
      default = self'.devShells.nix-shell;

      nix-shell = pkgs.mkShell {
        inputsFrom = [
          config.flake-root.devShell
          config.just-flake.outputs.devShell
          config.treefmt.build.devShell
          config.pre-commit.devShell
        ];

        packages = with pkgs;
          [git]
          ++ [direnv nix-direnv]
          ++ [just gnumake]
          ++ [shellcheck nil]
          ++ [devcontainer docker]
          ++ [nix-prefetch-docker];

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
    }
    // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      # linux has first class support for namespacing, the backend of docker
      # this means that we have a slightly simpler container interface available
      # with more capabilities on linux environments
      bwrapenv = self'.packages.devshell-bwrapenv.env;
    };

  # set up devshell commands
  just-flake.features = import ./just-flake.nix {
    inherit self self' inputs' pkgs;
  };
}

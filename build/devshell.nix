{
  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
    devShells = {
      default = pkgs.mkShell {
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
            # link the container makefile to the root of the workspace.
            ${lib.getExe' pkgs.coreutils "ln"} -snvrf ${self'.packages.makefile} "$FLAKE_ROOT/Makefile"

            # on Darwin environments, start up a Linux container for convenience.
            ${lib.strings.optionalString pkgs.stdenv.isDarwin ''
            ${lib.getExe pkgs.gnumake} -f ${self'.packages.makefile} container-up
          ''}
          fi
        '';
      };
    };
  };
}

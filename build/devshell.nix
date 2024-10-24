{
  perSystem = {
    config,
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
          # nix-build doesn't play very nice with the sticky bit
          # and /tmp in a docker environment. unsetting it enables
          # the container to manage its tmpfs as it pleases.
          if [[ -f /.dockerenv ]]; then
            unset TEMP TMPDIR NIX_BUILD_TOP
          fi
        '';
      };
    };
  };
}

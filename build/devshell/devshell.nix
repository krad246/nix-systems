{
  config,
  pkgs,
  ...
}:
pkgs.mkShell {
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
}

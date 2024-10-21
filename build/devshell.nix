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
          ++ [devcontainer docker];
      };
    };
  };
}

{
  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
    devShells = {
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
          ++ [just]
          ++ [shellcheck nil]
          ++ [devcontainer docker];

        shellHook = ''
          ${lib.getExe' pkgs.coreutils "ln"} -snvrf ${self'.packages.makefile} "$FLAKE_ROOT/Makefile"
        '';
      };
    };
  };
}

{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.treefmt.build.devShell
        config.pre-commit.devShell

        config.flake-root.devShell
      ];

      packages = with pkgs; [git direnv nix-direnv just ripgrep docker];
      shellHook = ''
      '';
    };
  };
}

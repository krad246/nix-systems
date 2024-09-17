{
  perSystem = {
    self',
    inputs',
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

        packages =
          (with pkgs;
            [git]
            ++ [direnv nix-direnv]
            ++ [just fd fzf ripgrep]
            ++ [uutils-coreutils nano]
            ++ [safe-rm]
            ++ [procps util-linux]
            ++ [nixFlakes nix-tree nil]
            ++ [docker dive]
            ++ [inputs'.agenix.packages.agenix])
          ++ (lib.optionals pkgs.stdenv.isLinux [pkgs.fuse pkgs.fuse3 pkgs.bindfs]);
      };
    };
  };
}

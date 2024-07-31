{inputs, ...}: {
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    pre-commit.settings.hooks = {
      nil.enable = true;
      deadnix.enable = true;
      alejandra.enable = true;
      statix.enable = true;
    };

    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.flake-root.devShell
        config.just-flake.outputs.devShell
        config.treefmt.build.devShell
        config.pre-commit.devShell
      ];

      packages = with pkgs; [git direnv nix-direnv just ripgrep];
    };

    packages = {
      nix-build-all = pkgs.writeShellApplication {
        name = "nix-build-all";
        text = ''
          ${lib.getExe pkgs.nix} flake lock --no-update-lock-file
          ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} . "$@"
        '';
      };
    };
  };
}

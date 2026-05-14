{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells = {
      default = pkgs.mkShell {
        packages =
          (with pkgs; [
            direnv
            lorri
            nix-direnv
            nix-output-monitor
          ])
          ++ [
            config.flake-root.package
          ];

        inputsFrom = with config; [
          flake-root.devShell
          just-flake.outputs.devShell
          pre-commit.devShell
          treefmt.build.devShell
        ];

        shellHook = ''
          # FLAKE_ROOT="$(flake-root)"
          # eval "$(lorri direnv --context $FLAKE_ROOT --flake $FLAKE_ROOT)"
          source ${lib.meta.getExe config.agenix-shell.installationScript}
        '';
      };
    };
  };
}

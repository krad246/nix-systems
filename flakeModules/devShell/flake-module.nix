# outer / 'flake' scope
args @ {
  inputs,
  self,
  ...
}: let
  justfile = import ./just-flake args;
in {
  imports =
    (with inputs; [
      treefmt-nix.flakeModule
      flake-root.flakeModule
      pre-commit-hooks-nix.flakeModule
      agenix-rekey.flakeModule
      agenix-shell.flakeModules.default
    ])
    ++ [justfile.flakeModule];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      justfile = justfile.flakeModule;
    };

    modules.flake = flakeModules;
  };

  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
    formatter = config.treefmt.build.wrapper;

    devShells =
      (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        bubblewrap = pkgs.mkShell {
          inputsFrom = [
            self'.devShells.interactive
          ];

          packages = [];
          shellHook = ''
            ${lib.meta.getExe self'.packages.bubblewrap}
          '';
        };
      })
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
        devcontainer = pkgs.mkShell {
          inputsFrom = [
            self'.devShells.interactive
          ];

          packages = [];

          shellHook = let
            parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
            arch = parse.cpu.name;
            makefile = self'.packages."makefile-${arch}-linux";
            devcontainer-json = self'.packages."devcontainer-json-${arch}-linux";
          in ''
            FLAKE_ROOT="$(${lib.meta.getExe config.flake-root.package})"
            ${lib.meta.getExe' pkgs.coreutils "ln"} -snvrf ${makefile} $FLAKE_ROOT/Makefile
            ${lib.meta.getExe' pkgs.coreutils "ln"} -snvrf ${devcontainer-json} $FLAKE_ROOT/.devcontainer.json
          '';
        };
      })
      // {
        interactive = pkgs.mkShell {
          inputsFrom = [
            self'.devShells.nix-shell
            config.just-flake.outputs.devShell
          ];

          packages =
            [
              self.packages.${pkgs.stdenv.system}.devour-flake
              self.packages.${pkgs.stdenv.system}.home-manager
            ]
            ++ (lib.lists.optionals pkgs.stdenv.isLinux [
              self.packages.${pkgs.stdenv.system}.nixos-rebuild
            ])
            ++ (lib.lists.optionals pkgs.stdenv.isDarwin [
              self.packages.${pkgs.stdenv.system}.darwin-rebuild
            ]);

          shellHook = ''
            FLAKE_ROOT="$(${lib.meta.getExe config.flake-root.package})"
            eval "$(${lib.meta.getExe pkgs.lorri} direnv --context $FLAKE_ROOT --flake $FLAKE_ROOT)"
          '';
        };

        nix-shell = pkgs.mkShell {
          packages = with pkgs;
            [git delta]
            ++ [direnv nix-direnv lorri]
            ++ [just gnumake]
            ++ [shellcheck nil]
            ++ [self.packages.${pkgs.stdenv.system}.nix];

          inputsFrom = [
            config.flake-root.devShell
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];

          shellHook = ''
          '';
        };

        # prefer an interpreter-level venv by default
        default = self'.devShells.nix-shell;
      };
  };
}

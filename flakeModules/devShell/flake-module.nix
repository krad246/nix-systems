{inputs, ...}: let
  justfile = ./just-flake;
in {
  imports =
    (with inputs; [
      treefmt-nix.flakeModule
      flake-root.flakeModule
      pre-commit-hooks-nix.flakeModule
      agenix-rekey.flakeModule
      agenix-shell.flakeModules.default
    ])
    ++ [justfile];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      inherit justfile;
    };

    modules.flake = flakeModules;
  };

  perSystem = {
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
            config.devShells.interactive
          ];

          packages = [];
          shellHook = ''
            ${lib.meta.getExe config.packages.bubblewrap}
          '';
        };
      })
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
        devcontainer = pkgs.mkShell {
          inputsFrom = [
            config.devShells.interactive
          ];

          packages = [
            pkgs.coreutils
          ];

          shellHook = let
            parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
            arch = parse.cpu.name;
            makefile = config.packages."makefile-${arch}-linux";
            devcontainer-json = config.packages."devcontainer-json-${arch}-linux";
          in ''
            ln -snvrf ${makefile} $FLAKE_ROOT/Makefile
            ln -snvrf ${devcontainer-json} $FLAKE_ROOT/.devcontainer.json
          '';
        };
      })
      // {
        interactive = pkgs.mkShell {
          inputsFrom = with config; [
            devShells.nix-shell
            just-flake.outputs.devShell
          ];

          packages =
            [pkgs.lorri]
            ++ [
              config.packages.devour-flake
              config.packages.home-manager
            ]
            ++ (lib.lists.optionals pkgs.stdenv.isLinux [
              config.packages.nixos-rebuild
            ])
            ++ (lib.lists.optionals pkgs.stdenv.isDarwin [
              config.packages.darwin-rebuild
            ]);

          shellHook = ''
            eval "$(lorri direnv --context $FLAKE_ROOT --flake $FLAKE_ROOT)"
          '';
        };

        nix-shell = pkgs.mkShell {
          packages = with pkgs;
            [git]
            ++ [direnv nix-direnv]
            ++ [just gnumake]
            ++ [shellcheck nil];
          # ++ [self.packages.${pkgs.stdenv.system}.nix];

          inputsFrom = with config; [
            flake-root.devShell
            treefmt.build.devShell
            pre-commit.devShell
          ];
        };

        # prefer JUST the tools by default
        default = config.devShells.nix-shell;
      };
  };
}

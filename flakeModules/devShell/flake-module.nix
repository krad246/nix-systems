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
    treefmt = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = true;
      programs = {
        alejandra.enable = true;
        deadnix = {
          enable = true;
          no-underscore = true;
        };
        dos2unix.enable = false;
        just.enable = true;
        keep-sorted.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        typos.enable = false;
      };
    };

    pre-commit = {
      settings = {
        excludes = ["\\.(age)$"];
        hooks = {
          alejandra.enable = true;
          check-added-large-files.enable = true;
          check-case-conflicts.enable = true;
          check-executables-have-shebangs.enable = true;
          check-merge-conflicts.enable = true;
          check-shebang-scripts-are-executable.enable = true;
          check-symlinks.enable = true;
          checkmake.enable = false;
          cspell = {
            enable = false;
          };
          deadnix.enable = true;
          detect-private-keys.enable = true;
          end-of-file-fixer.enable = false;
          flake-checker.enable = true;
          markdownlint.enable = false;
          mdl.enable = false;
          mixed-line-endings.enable = true;
          mkdocs-linkcheck.enable = false;
          nil.enable = true;
          ripsecrets.enable = true;
          shellcheck.enable = true;
          shfmt.enable = true;
          statix.enable = true;
          treefmt = {
            enable = true;
            settings = {fail-on-change = true;};
          };
          trim-trailing-whitespace.enable = true;
          trufflehog.enable = false;
        };
      };

      # it is redundant to run pre-commit hooks multiple times on the same code
      # it's not like anything changes between the behaviors cross system
      check.enable = true;
    };

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
      // {
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

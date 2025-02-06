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
    inputs',
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
    formatter = config.treefmt.build.wrapper;
    treefmt = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = false;
      programs = {
        alejandra.enable = true;
        deadnix = {
          enable = true;
          no-underscore = true;
        };
        dos2unix.enable = false;
        just.enable = false;
        keep-sorted.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        typos.enable = false;
      };
    };

    pre-commit = {
      settings.hooks = {
        alejandra.enable = true;
        check-added-large-files.enable = true;
        check-case-conflicts.enable = true;
        check-executables-have-shebangs.enable = false;
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
        flake-checker.enable = false;
        markdownlint.enable = false;
        mdl.enable = false;
        mixed-line-endings.enable = true;
        mkdocs-linkcheck.enable = false;
        nil.enable = true;
        ripsecrets.enable = false;
        shellcheck.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        treefmt = {
          enable = true;
          settings = {fail-on-change = true;};
        };
        trim-trailing-whitespace.enable = false;
        trufflehog.enable = false;
      };
      check.enable = false;
    };

    devShells = {
      interactive = pkgs.mkShell {
        inputsFrom = [
          self'.devShells.nix-shell-env
          config.just-flake.outputs.devShell
        ];

        shellHook = let
          parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
          arch = parse.cpu.name;
          makefile = self'.packages."makefile-${arch}-linux";
          devcontainer-json = self'.packages."devcontainer-json-${arch}-linux";
        in ''
          eval "$(${lib.meta.getExe pkgs.lorri} direnv --context $FLAKE_ROOT --flake $FLAKE_ROOT)"
          ${lib.meta.getExe' pkgs.coreutils "ln"} -snvrf ${makefile} $FLAKE_ROOT/Makefile
          ${lib.meta.getExe' pkgs.coreutils "ln"} -snvrf ${devcontainer-json} $FLAKE_ROOT/.devcontainer.json
        '';
      };

      nix-shell-env = pkgs.mkShell {
        packages = let
          inherit (lib.krad246) nixArgs;
          addFlags = x: "--add-flags ${lib.strings.escapeShellArg x}";
          wrapArgs = lib.strings.concatMapStringsSep " " addFlags nixArgs;
        in
          (with pkgs;
            [git delta]
            ++ [direnv nix-direnv lorri]
            ++ [just gnumake]
            ++ [shellcheck nil])
          ++ [
            (pkgs.symlinkJoin {
              name = "nix";
              paths = [pkgs.nixVersions.stable];
              buildInputs = [pkgs.makeWrapper];
              postBuild = ''
                wrapProgram $out/bin/nix ${wrapArgs}
              '';
            })
            (pkgs.symlinkJoin {
              name = "home-manager";
              paths = [inputs'.home-manager.packages.home-manager];
              buildInputs = [pkgs.makeWrapper];
              postBuild = ''
                wrapProgram $out/bin/home-manager ${wrapArgs} --add-flags '--flake ${self}' --add-flags '-b ${self.dirtyRev}'
              '';
            })
            (pkgs.symlinkJoin {
              name = "devour-flake";
              paths = [self'.packages.devour-flake];
              buildInputs = [pkgs.makeWrapper];
              postBuild = ''
                wrapProgram $out/bin/devour-flake ${wrapArgs}
              '';
            })
          ]
          ++ (lib.lists.optionals pkgs.stdenv.isLinux [
            (pkgs.symlinkJoin {
              name = "nixos-rebuild";
              paths = [pkgs.nixos-rebuild];
              buildInputs = [pkgs.makeWrapper];
              postBuild = ''
                wrapProgram $out/bin/nixos-rebuild ${wrapArgs} --add-flags '--use-remote-sudo' --add-flags '--flake ${self}'
              '';
            })
          ])
          ++ (lib.lists.optionals pkgs.stdenv.isDarwin [
            (pkgs.symlinkJoin {
              name = "darwin-rebuild";
              paths = [inputs'.darwin.packages.darwin-rebuild];
              buildInputs = [pkgs.makeWrapper];
              postBuild = ''
                wrapProgram $out/bin/darwin-rebuild ${wrapArgs} --add-flags '--flake ${self}'
              '';
            })
          ]);

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
      nix-shell = self'.devShells.nix-shell-env;
    };
  };
}

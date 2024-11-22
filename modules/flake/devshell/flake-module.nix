# outer / 'flake' scope
{
  importApply,
  self,
  inputs,
  ...
}: let
  justfile = import ./just-flake {inherit importApply self inputs;};
in {
  imports =
    (with inputs; [
      treefmt-nix.flakeModule
      flake-root.flakeModule
      pre-commit-hooks-nix.flakeModule
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
    pkgs,
    ...
  }: let
    inherit (pkgs) lib;
  in {
    formatter = config.treefmt.build.wrapper;
    treefmt = {
      inherit (config.flake-root) projectRootFile;
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

    pre-commit.settings.hooks = {
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
      end-of-file-fixer.enable = true;
      flake-checker.enable = false;
      markdownlint.enable = false;
      mdl.enable = false;
      mixed-line-endings.enable = true;
      mkdocs-linkcheck.enable = true;
      nil.enable = true;
      ripsecrets.enable = false;
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

    devShells =
      {
        # prefer an interpreter-level venv by default
        default = self'.devShells.nix-shell;
        nix-shell = self'.packages.nix-shell-env;
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        # linux has first class support for namespacing, the backend of docker
        # this means that we have a slightly simpler container interface available
        # with more capabilities on linux environments
        bwrapenv = self'.packages.devshell-bwrapenv.env;
      };
  };
}

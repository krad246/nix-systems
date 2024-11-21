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
        deadnix.enable = true;
        alejandra.enable = true;
        statix.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
      };
    };

    pre-commit.settings.hooks = {
      nil.enable = true;
      deadnix.enable = true;
      alejandra.enable = true;
      statix.enable = true;
      shellcheck.enable = true;
      shfmt.enable = true;
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

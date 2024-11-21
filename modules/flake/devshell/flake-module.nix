# outer / 'flake' scope
{
  importApply,
  self,
  ...
}: let
  justfile = import ./just-flake {inherit importApply self;};
in {
  imports = [justfile.flakeModule];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      justfile = justfile.flakeModule;
    };

    modules.flake = flakeModules;
  };

  perSystem = {
    self',
    pkgs,
    ...
  }: let
    inherit (pkgs) lib;
  in {
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

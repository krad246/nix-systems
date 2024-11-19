{
  self,
  self',
  inputs',
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

  # set up devshell commands
  just-flake.features = import ./just-flake.nix {
    inherit self self' inputs' pkgs;
  };
}

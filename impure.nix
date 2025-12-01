{system ? builtins.currentSystem, ...}: let
  flake = import ./default.nix;
in
  flake.legacyPackages.${system}

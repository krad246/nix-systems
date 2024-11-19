{
  withSystem,
  flake-parts-lib,
  self,
  inputs,
  ...
}: let
  inherit (flake-parts-lib) importApply;
in {
  # importApply basically curries / partially applies some extra arguments to the existing argument
  # list of a module
  flakeModule = importApply ./flake-module.nix {inherit withSystem importApply self inputs;};
}

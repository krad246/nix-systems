{
  withSystem,
  flake-parts-lib,
  self,
  inputs,
  ...
}: let
  inherit (flake-parts-lib) importApply;
in {
  flakeModule = importApply ./flake-module.nix {inherit withSystem importApply self inputs;};
}

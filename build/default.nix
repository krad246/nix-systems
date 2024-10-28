{
  withSystem,
  flake-parts-lib,
  self,
  ...
}: let
  inherit (flake-parts-lib) importApply;
in {
  flakeModule = importApply ./flake-module.nix {inherit withSystem importApply self;};
}

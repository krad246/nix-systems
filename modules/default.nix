{
  getSystem,
  moduleWithSystem,
  withSystem,
  importApply,
  inputs,
  self,
  lib,
  ...
}: let
  forwarded = {
    inherit getSystem moduleWithSystem withSystem;
    inherit importApply;
    inherit inputs self;
    inherit lib;
  };
in {
  flakeModule = importApply ./flake-module.nix forwarded;
}

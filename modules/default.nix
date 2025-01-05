# importing the parent directory passes through here first.
# the flake-parts library entrypoint forwards arguments through.
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
  # 'curry' the flake module with these extra arguments
  flakeModule = importApply ./flake-module.nix forwarded;
}

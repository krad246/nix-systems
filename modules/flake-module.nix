{
  withSystem,
  importApply,
  self,
  inputs,
  lib,
  ...
}: let
  entrypoint = import ./flake {inherit withSystem importApply self lib inputs;};
in
  {...}: {
    # pull in the default flake module so that we can, y'know, build stuff...
    imports =
      (with inputs; [
        flake-parts.flakeModules.modules
        flake-parts.flakeModules.flakeModules
      ])
      ++ [entrypoint.flakeModule];
  }

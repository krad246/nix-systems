args @ {inputs, ...}: let
  entrypoint = import ./flake args;
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

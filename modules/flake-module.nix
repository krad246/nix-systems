# this is a trampoline layer to the real implementation of the entire flake
# it pulls in flake-parts library dependencies to facilitate the flake module
# structural pattern
args @ {inputs, ...}: let
  entrypoint = import ./flake args;
in
  {...}: {
    imports =
      (with inputs; [
        flake-parts.flakeModules.modules
        flake-parts.flakeModules.flakeModules
      ])
      ++ [entrypoint.flakeModule];
  }

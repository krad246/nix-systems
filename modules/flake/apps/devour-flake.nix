{
  lib,
  self',
  ...
}: {
  type = "app";
  program = lib.meta.getExe self'.packages.devour-flake;
  meta.description = "Build all flake outputs in parallel.";
}

{
  inputs,
  lib,
  ...
}: {
  imports = lib.lists.optionals (inputs ? flake-root) [
    inputs.flake-root.flakeModule
  ];

  flake-file = {
    inputs = {
      flake-root.url = "github:srid/flake-root";
    };
  };
}

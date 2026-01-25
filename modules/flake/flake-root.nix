{inputs, ...}: {
  imports = [
    inputs.flake-root.flakeModule
  ];

  flake-file = {
    inputs = {
      flake-root.url = "github:srid/flake-root";
    };
  };
}

{
  inputs,
  lib,
  ...
}: {
  imports = lib.lists.optionals (inputs ? pkgs-by-name-for-flake-parts) [
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  flake-file.inputs = {
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
  };

  perSystem = lib.modules.mkIf (inputs ? pkgs-by-name-for-flake-parts) {
    pkgsDirectory = ../../pkgs;
  };
}

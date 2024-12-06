{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [./nixbook-air.nix];
    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint

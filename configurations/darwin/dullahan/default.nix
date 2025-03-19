{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./configuration.nix
      ./hercules-ci.nix
      ./secrets.nix
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint

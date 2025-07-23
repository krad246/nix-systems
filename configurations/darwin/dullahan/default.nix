{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./configuration.nix
      ./hercules-ci-agent
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint

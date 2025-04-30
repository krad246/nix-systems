{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./configuration.nix
      ./hercules-ci-agent
      ./remotes.nix
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint

{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./configuration.nix
      ./hercules-ci/dullahan.nix
      ./hercules-ci/headless-penguin.nix
      ./remotes.nix
      ./secrets.nix
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint

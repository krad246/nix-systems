{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./brew-casks.nix
      ./nixbook-air.nix
      ./remotes.nix
    ];
    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint

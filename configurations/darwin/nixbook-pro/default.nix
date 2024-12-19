{withSystem, ...}: let
  entrypoint = {system, ...}: {
    imports = [
      ./remotes.nix
      ./software
      ./system-settings.nix
    ];

    nixpkgs.system = system;
  };
in
  withSystem "aarch64-darwin" entrypoint

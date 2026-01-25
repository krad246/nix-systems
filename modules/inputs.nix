{inputs, ...}: {
  imports = [
    inputs.flake-file.flakeModules.default
  ];

  flake-file = {
    inputs = {
      systems.url = "github:nix-systems/default";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-file.url = "github:vic/flake-file";
      flake-compat.url = "github:edolstra/flake-compat";
    };
  };

  systems = import inputs.systems;
}

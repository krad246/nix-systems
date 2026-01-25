{inputs, ...}: {
  imports = [
    inputs.flake-file.flakeModules.default
  ];

  flake-file = {
    inputs = {
      systems.url = "github:nix-systems/default";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-file.url = "github:vic/flake-file";
    };

    prune-lock.enable = true;
  };

  systems = import inputs.systems;
}

{
  inputs,
  lib,
  ...
}: {
  imports =
    [
      inputs.flake-file.flakeModules.dendritic
    ]
    ++ lib.lists.optionals (inputs ? nix-auto-follow) [
      inputs.flake-file.flakeModules.nix-auto-follow
    ];

  flake-file = {
    formatter = lib.modules.mkDefault (pkgs: pkgs.alejandra);

    inputs = {
      systems.url = "github:nix-systems/default";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-file.url = "github:vic/flake-file";
      flake-compat.url = "github:edolstra/flake-compat";
    };

    prune-lock.enable = true;
  };

  systems = import inputs.systems;
}

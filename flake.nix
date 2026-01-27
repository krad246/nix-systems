# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: import ./outputs.nix inputs;

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://krad246.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "krad246.cachix.org-1:N57J9SfNFtxMSYnlULH4l7ZkdNjIQb0ByyapaEb/8IM="
    ];
  };

  inputs = {
    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-shell.url = "github:aciceri/agenix-shell";
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    dconf2nix = {
      flake = false;
      url = "github:nix-community/dconf2nix/master";
    };
    devour-flake = {
      flake = false;
      url = "github:srid/devour-flake";
    };
    disko.url = "github:nix-community/disko";
    ez-configs.url = "github:ehllie/ez-configs";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    hercules-ci-agent.url = "github:hercules-ci/hercules-ci-agent/hercules-ci-agent-0.10.5";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    impermanence.url = "github:nix-community/impermanence";
    just-flake.url = "github:juspay/just-flake";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nixGL.url = "github:nix-community/nixGL";
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/nixos-wsl/main";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
}

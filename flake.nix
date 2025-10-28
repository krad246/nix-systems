{
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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # WSL distribution on NixOS
    nixos-wsl.url = "github:nix-community/nixos-wsl/main";

    # Darwin shims for Nix
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";

    # Cross-platform (Linux / MacOS) userspace package management
    home-manager.url = "github:nix-community/home-manager/release-25.05";

    # Flake-Parts module gluing it together
    ez-configs.url = "github:ehllie/ez-configs";

    # Hardware platform configurations with options preset
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Simple modules for generating a variety of image formats
    nixos-generators.url = "github:nix-community/nixos-generators";

    # Immutable OS root filesystem (erase your darlings)
    impermanence.url = "github:nix-community/impermanence";

    # Declarative disk partitioning
    disko.url = "github:nix-community/disko";

    # Nix User Repositories
    # out-of-band package management
    nur.url = "github:nix-community/NUR";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    # Legacy and flake compatibility shims.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # An opinionated Nix flake library (see flake-utils)
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Simple connection glue between direnv, nix-shell, and flakes to get
    # the absolute roots of various subflakes in a project.
    flake-root.url = "github:srid/flake-root";

    # Consumer flake to build all outputs in this flake
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };

    # Glue logic between just and Nix (replacement to mission-control)
    just-flake.url = "github:juspay/just-flake";

    # Swiss-army-knife formatter.
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # Code cleanliness checking for developers.
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";

    # hercules CI support
    hercules-ci-agent.url = "github:hercules-ci/hercules-ci-agent/hercules-ci-agent-0.10.5";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";

    # Handles the Spotlight and Dock synchronization
    mac-app-util.url = "github:hraban/mac-app-util";

    # AGE encrypted secrets
    # Handle rekeying via Yubikey, etc.
    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-shell.url = "github:aciceri/agenix-shell";

    # window manager stuff

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

    dconf2nix = {
      url = "github:nix-community/dconf2nix/master";
      flake = false;
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixGL.url = "github:nix-community/nixGL";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake
    # Environment
    {
      inherit inputs;
    }
    ({self, ...}: let
      apps = ./flakeModules/apps;
      checks = ./flakeModules/checks;
      devShell = ./flakeModules/devShell;
      ezConfigs = ./flakeModules/ezConfigs; # ties system and home configurations together
      herculesCI = ./flakeModules/herculesCI;
      legacyPackages = ./flakeModules/legacyPackages;
      overlays = ./flakeModules/overlays;
      packages = ./flakeModules/packages;

      toplevel = {
        imports = [
          apps
          checks
          devShell
          ezConfigs
          herculesCI
          legacyPackages
          overlays
          packages
        ];
      };
    in {
      # the rest of our options perSystem, etc. are set through the flakeModules.
      # keeps code localized per directory
      imports =
        [
          flake-parts.flakeModules.flakeModules
          flake-parts.flakeModules.modules
        ]
        ++ [
          toplevel
        ]
        ++ [
          flake-parts.flakeModules.partitions
        ];

      flake = rec {
        flakeModules = {
          default = toplevel;

          inherit apps;
          inherit checks;
          inherit devShell;
          inherit ezConfigs;
          inherit herculesCI;
          inherit legacyPackages;
          inherit overlays;
          inherit packages;
        };

        # use these for the options namespaces of system / home configurations
        modules = {
          flake = flakeModules; # alias output name

          # ezConfigs does the heavy lifting of figuring these out for us

          nixos = self.nixosModules;
          darwin = self.darwinModules;
          home = self.homeModules;

          # can be used in all of the above contexts
          generic = let
            inherit (self.lib) krad246;
            paths = krad246.fileset.filterExt "nix" ./modules/generic;
          in
            krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path (import path));
        };
      };

      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    });
}

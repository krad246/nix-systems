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
      "krad246.cachix.org-1:naxMicfqW5ZWr7XNZeLfAT3YHWCDLs3noY0aI3eBfvQ="
    ];
  };

  inputs = rec {
    # Package branches

    # system specific channels
    nixos-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-2405-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixos-2411-small.url = "github:NixOS/nixpkgs/nixos-24.11-small";

    # generic rolling release branches
    # they're always tracking the latest release
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # stable nixos points at 24.05
    # generic stable nixpkgs also points to it but can move ahead if desired
    nixos-stable = nixos-2405;

    # specifically use stable NixOS for WSL, but otherwise flexible
    nixpkgs-wsl = nixos-stable;

    # nixpkgs for home has to be in the same release 'family'
    # as the system channels
    nixpkgs-nixos = nixos-2405;
    nixpkgs-darwin = nixpkgs-2405-darwin;
    nixpkgs-home = nixos-2405;

    # the flake input 'nixpkgs' is the channel we are using in our flake for the evaluation, as
    # we've overridden the nixpkgs inputs to all of our output derivations.
    # thus nixpkgs is approximately the same thing as nixpkgs-lib for our purpose.
    nixpkgs = nixpkgs-home;
    nixpkgs-lib = nixpkgs;

    # Legacy and flake compatibility shims.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Simple connection glue between direnv, nix-shell, and flakes to get
    # the absolute roots of various subflakes in a project.
    flake-root.url = "github:srid/flake-root";

    # Consumer flake to build all outputs in this flake
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    # An opinionated Nix flake library (see flake-utils)
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    # Glue logic between just and Nix (replacement to mission-control)
    just-flake = {
      url = "github:juspay/just-flake";
    };

    # Swiss-army-knife formatter.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Code cleanliness checking for developers.
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixos-stable";
      };
    };

    # WSL distribution on NixOS
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/main";
      inputs = {
        nixpkgs.follows = "nixpkgs-wsl";
        flake-compat.follows = "flake-compat";
      };
    };

    # Darwin shims for Nix
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Cross-platform (Linux / MacOS) userspace package management
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-home";
    };

    # Flake-Parts module gluing it together
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # Hardware platform configurations with options preset
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # Simple modules for generating a variety of image formats
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Immutable OS root filesystem (erase your darlings)
    impermanence.url = "github:nix-community/impermanence";

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AGE encrypted secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
      };
    };

    # Handle rekeying via Yubikey, etc.
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks-nix";
    };

    # Handles the Spotlight and Dock synchronization
    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "darwin";
      };
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixos-stable";
        flake-compat.follows = "flake-compat";
      };
    };

    dconf2nix = {
      url = "github:nix-community/dconf2nix/master";
      flake = false;
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    nixvim-config.url = "github:mikaelfangel/nixvim-config";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ez-configs,
    ...
  }: let
    lib =
      inputs.nixpkgs.lib.extend
      (_final: _prev: (import ./lib));
  in
    flake-parts.lib.mkFlake
    # Environment
    {
      inherit inputs;
      specialArgs = {inherit lib;};
    }
    # Entrypoint
    ({
      withSystem,
      flake-parts-lib,
      ...
    }: let
      args = {
        inherit withSystem flake-parts-lib;
        inherit self lib inputs;
      };
    in {
      # Source files and other callables pulled in here are combined into this 'layer'.
      # flake-parts specifies that flake-level functors and other reusable module logic
      # are captured in flakeModules.
      imports =
        (with inputs; [
          treefmt-nix.flakeModule
          flake-root.flakeModule
          ez-configs.flakeModule
          pre-commit-hooks-nix.flakeModule
          just-flake.flakeModule
          flake-parts.flakeModules.modules
          flake-parts.flakeModules.flakeModules
        ])
        ++ [
          (import ./modules args).flakeModule
          (import ./modules/flake args).flakeModule
        ];

      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    });
}

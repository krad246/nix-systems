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
    # generic rolling release branches
    # they're always tracking the latest release
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # generic stable nixpkgs also points to it but can move ahead if desired
    nixos-stable = {url = "github:NixOS/nixpkgs/nixos-25.05";};

    # specifically use stable NixOS for WSL, but otherwise flexible
    nixpkgs-wsl = {url = "github:NixOS/nixpkgs/nixos-25.05";};

    # nixpkgs for home has to be in the same release 'family'
    # as the system channels
    nixpkgs-nixos = {url = "github:NixOS/nixpkgs/nixos-25.05";};
    nixpkgs-darwin = {url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";};
    nixpkgs-home = {url = "github:NixOS/nixpkgs/nixos-25.05";};

    # the flake input 'nixpkgs' is the channel we are using in our flake for the evaluation, as
    # we've overridden the nixpkgs inputs to all of our output derivations.
    # thus nixpkgs is approximately the same thing as nixpkgs-lib for our purpose.
    nixpkgs = {url = "github:NixOS/nixpkgs/nixos-25.05";};
    nixpkgs-lib = {url = "github:NixOS/nixpkgs/nixos-25.05";};

    # Nix User Repositories
    nur = {
      url = "github:nix-community/NUR";
    };

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
    };

    # Glue logic between just and Nix (replacement to mission-control)
    just-flake = {
      url = "github:juspay/just-flake";
    };

    # Swiss-army-knife formatter.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix/48961f31e992e43203afb2ea9cb1402ad392d94b";
    };

    # Code cleanliness checking for developers.
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
    };

    # WSL distribution on NixOS
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/main";
    };

    # Darwin shims for Nix
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    };

    # Cross-platform (Linux / MacOS) userspace package management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
    };

    # Flake-Parts module gluing it together
    ez-configs = {
      url = "github:ehllie/ez-configs";
    };

    # Hardware platform configurations with options preset
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # Simple modules for generating a variety of image formats
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
    };

    # Immutable OS root filesystem (erase your darlings)
    impermanence.url = "github:nix-community/impermanence";

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
    };

    # AGE encrypted secrets
    agenix = {
      url = "github:ryantm/agenix";
    };

    # Handle rekeying via Yubikey, etc.
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
    };

    agenix-shell = {
      url = "github:aciceri/agenix-shell";
    };

    # Handles the Spotlight and Dock synchronization
    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
    };

    dconf2nix = {
      url = "github:nix-community/dconf2nix/master";
      flake = false;
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    nixpkgs-mozilla.url = "github:mozilla/nixpkgs-mozilla";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    nixvim-config.url = "github:mikaelfangel/nixvim-config";
    hercules-ci-agent.url = "github:hercules-ci/hercules-ci-agent/hercules-ci-agent-0.10.5";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }: let
    lib = inputs.nixpkgs.lib.extend (_self: _super:
      import ./lib {
        lib = _super;
      });
  in
    flake-parts.lib.mkFlake
    # Environment
    {
      inherit inputs;
      specialArgs = {
        inherit lib;
      };
    }
    # Entrypoint
    ({
      getSystem,
      moduleWithSystem,
      withSystem,
      flake-parts-lib,
      ...
    }: let
      args = {
        inherit getSystem moduleWithSystem withSystem;
        inherit (flake-parts-lib) importApply;
        inherit inputs self;
        inherit lib;
      };

      # pull the flake module into this context
      # this encompasses passing through a default.nix, capturing
      # calling context, and then attaching it to a flake-module.nix that
      # provides the actual implementation; it provides a callable through the flakeModule attribute
      entrypoint = import ./flakeModules args;
    in {
      # Source files and other callables pulled in here are combined into this 'layer'.
      # flake-parts specifies that flake-level functors and other reusable module logic
      # are captured in flakeModules.
      imports = [
        entrypoint.flakeModule
      ];

      # export lib from above
      flake = {inherit lib;};

      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    });
}

{
  inputs = rec {
    # Package distributions
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";

    nixpkgs = nixpkgs-stable;

    # Legacy and modern Nix compatibility shims.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Simple glue between direnv, nix-shell, and flakes to get
    # absolutely reproducible pathing in the repo.
    flake-root.url = "github:srid/flake-root";

    # Swiss-army-knife formatter.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Code commit cleanliness.
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };

    # An opinionated Nix flake library (see flake-utils)
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Darwin shims for Nix
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Handles the Spotlight and Dock synchronization
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.flake-compat.follows = "flake-compat";
    };

    # Cross-platform (Linux / MacOS) userspace package management
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # For WSL
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    # Flake-Parts module gluing it together
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ez-configs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = with inputs;
        [
          treefmt-nix.flakeModule
          flake-root.flakeModule
          ez-configs.flakeModule
          pre-commit-hooks-nix.flakeModule
        ]
        ++ [./tools];

      flake = {
        packages = {
        };

        # Live running system

        # Deployable ISO image

        # Deployable NixOS initial generation + live reloading package.
      };

      # mkFlake expects this to be present,
      # so even if we don't use anything from perSystem, we need to set it to something.
      # You can set it to anything you want if you also want to provide perSystem outputs in your flake.
      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];

      ezConfigs = {
        root = ./.;
        globalArgs = {inherit self inputs;};
        home = {
          extraSpecialArgs = {
            inherit self inputs;
            imports = with inputs; [
              agenix.homeManagerModule
              mac-app-util.homeManagerModule
            ];
          };

          users = {
          };
        };
      };
    };
}

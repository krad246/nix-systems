{
  inputs = rec {
    # Package distributions
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";

    nixpkgs = nixpkgs-stable;

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
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

    # Flake-Parts module gluing it together
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # Legacy and flake compatibility shims.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Simple connection glue between direnv, nix-shell, and flakes to get
    # the absolute roots of various subflakes in a project.
    flake-root.url = "github:srid/flake-root";

    # An opinionated Nix flake library (see flake-utils)
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
    };

    # Swiss-army-knife formatter.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Code cleanliness checking for developers.
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };

    # Deployment scripts + other bits n bobs
    mission-control.url = "github:Platonic-Systems/mission-control";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
      };
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
        ++ [
          mission-control.flakeModule
        ]
        ++ [./tools];

      flake = {
        packages = {
          "x86_64-linux" =
            (let
              inherit (self.nixosConfigurations) nixos-pantheon;
              inherit (nixos-pantheon.config.system) build;
            in {
              nixos-pantheon-vm = build.vm;
              nixos-pantheon-vm-with-bootloader = build.vmWithBootLoader;
            })
            // (let
              inherit (self.nixosConfigurations) nixos-iso-installer;
              inherit (nixos-iso-installer.config.system) build;
            in {nixos-iso-installer = build.isoImage;})
            // (let
              inherit (self.nixosConfigurations) nixos-wsl;
              inherit (nixos-wsl.config.system) build;
            in {
              nixos-wsl-tarball = build.tarballBuilder;
            });
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
        globalArgs = {inherit inputs;};
        home = {
          extraSpecialArgs = {
            inherit inputs;
            imports = with inputs; [
              agenix.homeManagerModule
              mac-app-util.homeManagerModule
            ];
          };

          users = {
            # Generate only one WSL config; requires a matching Windows user.
            keerad.nameFunction = _host: "keerad@nixos-wsl";

            # Generate a config for all OS's but handle special hosts with conditional imports
            # The name of the source file maps to the actual generated targets
            krad246.nameFunction = host: (
              if builtins.elem host ["nixbook-air"]
              then "krad246-darwin@nixbook-air"
              else "krad246@${host}"
            );

            # TODO: Figure out how to unify these outputs with the flake interface outside of perSystem
            # IDEA: export krad246@nixbook-air as a package that consumes krad246-darwin@nixbook-air
            # Can generate a flake output that is self referential to merge these disparate sites
          };
        };
      };
    };
}

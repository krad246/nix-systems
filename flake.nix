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
    # Package distributions
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

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
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    # WSL distribution on NixOS
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

    # Cross-platform (Linux / MacOS) userspace package management
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
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
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit lib;};
    } {
      imports =
        (with inputs; [
          treefmt-nix.flakeModule
          flake-root.flakeModule
          ez-configs.flakeModule
          pre-commit-hooks-nix.flakeModule
          just-flake.flakeModule
        ])
        ++ [
          ./build/devshell.nix
          ./build/docker-builder.nix
          ./build/formatter.nix
          ./build/just-flake.nix
        ];

      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];

      perSystem = {
        self',
        pkgs,
        lib,
        system,
        ...
      }: let
        nixosHosts = lib.attrsets.attrValues self.nixosConfigurations;
        withSystem = nixosCfg:
          nixosCfg.extendModules {
            modules = [
              {
                nixpkgs.hostPlatform = system;
              }
            ];
          };
        nixosConfigs = lib.lists.forEach nixosHosts withSystem;

        declaredFormats = nixosCfg: let
          formats =
            lib.attrsets.attrByPath ["config" "formats"] {}
            nixosCfg;
        in
          formats;

        hostFormatName = nixosCfg: format: let
          inherit (nixosCfg.config.networking) hostName;
        in "${hostName}/${format}";

        mapHostFormat = nixosCfg: format: value:
          lib.attrsets.nameValuePair
          (hostFormatName nixosCfg format)
          value;
      in {
        packages = let
          mkFormatPackages = nixosCfg: let
            declared = declaredFormats nixosCfg;
          in
            lib.attrsets.mapAttrs' (format: drv: mapHostFormat nixosCfg format drv)
            declared;

          formats = lib.lists.forEach nixosConfigs mkFormatPackages;
          nixos-install-unattended = pkgs.writeShellScriptBin "nixos-install-unattended" ''
            FLAKE_ROOT=${self} sudo --preserve-env=FLAKE_ROOT ${lib.getExe' pkgs.disko "disko-install"} \
              --flake "$FLAKE_ROOT#$HOSTNAME" \
              --extra-files "$FLAKE_ROOT" /opt/nixos \
              --option inputs-from "$FLAKE_ROOT" \
              --option experimental-features 'nix-command flakes' \
              --write-efi-boot-entries \
              --system-config '${builtins.toJSON (import ./nixos-modules/flatpak.nix)}' \
            "$@"
          '';
        in
          lib.attrsets.mergeAttrsList (lib.lists.flatten [
            (lib.lists.optionals pkgs.stdenv.isLinux [formats])
            (lib.lists.optionals pkgs.stdenv.isLinux [{inherit nixos-install-unattended;}])
          ]);

        apps =
          lib.attrsets.mapAttrs (_pname: drv: {
            type = "app";
            program = lib.getExe drv;
          })
          self'.packages;
      };

      ezConfigs = {
        root = ./.;
        globalArgs = {inherit self inputs;};

        nixos.hosts = {
          nixos-wsl.userHomeModules = ["keerad" "krad246"];
          immutable-gnome.userHomeModules = ["krad246"];
        };

        darwin.hosts = {
          nixbook-air.userHomeModules = ["krad246"];
          dullahan.userHomeModules = ["krad246"];
        };

        home = {
          users = {
            keerad = {
              # Generate only one WSL config; requires a matching Windows user
              nameFunction = _name: "keerad@nixos-wsl";

              # Standalone configuration independent of the host
              standalone = let
                inherit (inputs) nixpkgs;
                impure = builtins ? currentSystem;
                system =
                  if impure
                  then builtins.currentSystem
                  else throw "Cannot build the
                standalone configuration in pure mode!";
                pkgs = import nixpkgs {inherit system;};
              in {
                enable = impure;
                inherit pkgs;
              };
            };
          };
        };
      };
    };
}

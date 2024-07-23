{
  nixConfig = {
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

    extra-experimental-features = "nix-command flakes";
  };

  inputs = rec {
    # Package distributions
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs = nixpkgs-stable;

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

    # Glue logic between just and Nix (replacement to mission-control)
    just-flake = {
      url = "github:juspay/just-flake";
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

    # Hardware platform configurations with options preset
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Simple modules for generating a variety of image formats
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Immutable OS root filesystem (erase your darlings)
    impermanence.url = "github:nix-community/impermanence";

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # AGE encrypted secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
      };
    };

    # Handle rekeying via Yubikey, etc.
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Handles the Spotlight and Dock synchronization
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.flake-compat.follows = "flake-compat";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ez-configs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = with inputs; [
        treefmt-nix.flakeModule
        flake-root.flakeModule
        ez-configs.flakeModule
        pre-commit-hooks-nix.flakeModule
        just-flake.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];

      perSystem = {
        config,
        lib,
        pkgs,
        inputs',
        ...
      }: {
        # Configure repository formatter
        formatter = config.treefmt.build.wrapper;
        treefmt = {
          inherit (config.flake-root) projectRootFile;
          programs = {
            deadnix.enable = true;
            alejandra.enable = true;
            statix.enable = true;
          };
        };

        # flake-root determines location of this flake programmatically.

        # Add justfile bindings to the flake environment
        just-flake.features = let
          # Compose a simple just target from the name of the incoming derivation
          mkJustRecipe = args @ {
            drv,
            os,
            extraArgs,
            ...
          }: let
            # Conditionally include an alias line if an alias is passd
            maybeString = pred: val: lib.strings.optionalString pred val;
            mkAlias = alias: pname: "alias ${alias} := ${pname}";

            # Extract the package symbolic name without the version
            name = lib.strings.getName drv;
            version = lib.strings.getVersion drv;
            pname = lib.strings.removePrefix "-${version}" name;
          in ''
            # `${pname}` related subcommands. Syntax: just ${pname} <subcommand>
            [${os}]
            ${pname} VERB *ARGS:
              ${lib.meta.getExe drv} {{ VERB }} ${extraArgs} {{ ARGS }}

            ${maybeString (args ? alias) (mkAlias args.alias pname)}
          '';

          commonArgs = "--option experimental-features 'nix-command flakes' --option inputs-from \"FLAKE_ROOT\"";
          flakeArgs = "--flake \"$FLAKE_ROOT\"";
          builderArgs = commonArgs + flakeArgs;
        in {
          treefmt.enable = true;

          # Add a wrapper around nixos-rebuild to devShell instances if we're on Linux
          nixos-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
            enable = true;
            justfile = mkJustRecipe {
              drv = pkgs.nixos-rebuild;
              os = "linux";
              extraArgs = builderArgs + "--use-remote-sudo";
              alias = "nixos";
            };
          };

          # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
          darwin-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
            enable = true;
            justfile = mkJustRecipe {
              drv = inputs'.darwin.packages.darwin-rebuild;
              os = "macos";
              extraArgs = builderArgs;
              alias = "darwin";
            };
          };

          # Home configs work on all *nix systems
          home-manager = {
            enable = true;
            justfile = mkJustRecipe {
              drv = pkgs.home-manager;
              os = "unix";
              extraArgs = builderArgs + "-b bak";
              alias = "home";
            };
          };

          # nix works on all *nix systems
          nix = {
            enable = true;
            justfile = mkJustRecipe {
              drv = pkgs.nixFlakes;
              os = "unix";
              extraArgs = commonArgs;
            };
          };

          # TODO: generally functions same as 'switch X'
          # unless X is an output that must be deployed or otherwise installed
          # this implies that a builder script that is already known by this build system can /
          # should be callable through this target.
          install = {
            enable = true;
            justfile = ''
              install TARGET *ARGS:
                exec just nix run .#{TARGET}-installer -- {{ ARGS }}
            '';
          };
        };

        # Make commit actions also use something similar to treefmt
        pre-commit.settings.hooks = {
          cspell.enable = false;

          nil.enable = true;

          deadnix.enable = true;
          alejandra.enable = true;
          statix.enable = true;
        };

        # Create devShell with all features above
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.flake-root.devShell
            config.just-flake.outputs.devShell
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];

          packages = with pkgs; [git direnv nix-direnv just ripgrep];
          shellHook = ''
          '';
        };
      };

      ezConfigs = {
        root = ./.;
        globalArgs = {inherit self inputs;};
        nixos.hosts = {
          nixos-wsl.userHomeModules = ["keerad" "krad246"];
          nixos-iso-installer.userHomeModules = ["nixos"];
          immutable-gnome.userHomeModules = ["krad246"];
        };
        darwin.hosts.nixbook-air.userHomeModules = ["krad246"];
        home = {
          users = {
            # Generate only one WSL config; requires a matching Windows user.
            keerad = {
              nameFunction = _host: "keerad@nixos-wsl";
              standalone = {
                enable = builtins ? currentSystem;
                pkgs = import inputs.nixpkgs {system = builtins.currentSystem;};
              };
            };
          };
        };
      };

      flake = {
        agenix-rekey = inputs.agenix-rekey.configure {
          userFlake = self;
          nodes = self.nixosConfigurations;
        };

        packages = {
          "x86_64-linux" =
            (let
              inherit (self.nixosConfigurations) nixos-iso-installer;
              inherit (nixos-iso-installer.config.system) build;
            in {nixos-iso-installer = build.isoImage;})
            // (let
              inherit (self.nixosConfigurations) nixos-wsl;
              inherit (nixos-wsl.config.system) build;
            in {
              nixos-wsl-tarball = build.tarballBuilder;
            })
            // (let
              inherit (self.nixosConfigurations) immutable-gnome;
              inherit (immutable-gnome.config.system) build;
            in {immutable-gnome-vm = build.vmWithBootLoader;});
        };
      };
    };
}

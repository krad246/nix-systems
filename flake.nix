{
  nixConfig = {
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
              ${lib.meta.getExe drv} {{ VERB }} ${lib.strings.concatStringsSep " " extraArgs} {{ ARGS }}

            ${maybeString (args ? alias) (mkAlias args.alias pname)}
          '';

          flakeRoot = "\"$FLAKE_ROOT\"";
          commonArgs = ["--option experimental-features 'nix-command flakes'" "--option inputs-from ${flakeRoot}"];
          flakeArgs = ["--flake ${flakeRoot}"];
          builderArgs = commonArgs ++ flakeArgs;
        in {
          treefmt.enable = true;

          # Add a wrapper around nixos-rebuild to devShell instances if we're on Linux
          nixos-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
            enable = true;
            justfile = mkJustRecipe {
              drv = pkgs.nixos-rebuild;
              os = "linux";
              extraArgs = builderArgs ++ ["--use-remote-sudo"];
              alias = "os";
            };
          };

          # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
          darwin-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
            enable = true;
            justfile = mkJustRecipe {
              drv = inputs'.darwin.packages.darwin-rebuild;
              os = "macos";
              extraArgs = builderArgs;
              alias = "os";
            };
          };

          # Home configs work on all *nix systems
          home-manager = {
            enable = true;
            justfile = mkJustRecipe {
              drv = pkgs.home-manager;
              os = "unix";
              extraArgs = builderArgs ++ ["-b bak"];
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
                exec ${lib.getExe pkgs.just} nix run .#{{TARGET}}-installer -- {{ ARGS }}
            '';
          };

          check = {
            enable = true;
            justfile = ''
              check *ARGS: fmt
               exec ${lib.getExe pkgs.just} nix flake check {{ ARGS }}
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

        packages = {
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
          nixos-iso-installer = self.nixosConfigurations.nixos-iso-installer.config.formats.iso;
        };
      };
    };
}

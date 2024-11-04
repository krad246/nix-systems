{
  withSystem,
  self,
  inputs,
  ...
}: {
  # These modules are pretty large but are otherwise structured to merge against
  # the options layers touched below.
  imports = [
    # Sets up container image packages, custom devShell derivation within the container
    # VSCode *is* supported!
    ./containers

    # Map a list of valid nixos-generators formats declared by the flake's nixosConfigurations
    # to package derivations that we can directly build.
    ./nixos-generators.nix
  ];

  ezConfigs = {
    root = self;
    globalArgs = {inherit self inputs;};

    nixos.hosts = {
      windex.userHomeModules = ["keerad" "krad246"];
      fortress.userHomeModules = ["krad246"];
    };

    darwin.hosts = {
      nixbook-air.userHomeModules = ["krad246"];
      nixbook-pro.userHomeModules = ["krad246"];
      dullahan.userHomeModules = ["krad246"];
    };

    home = {
      users = {
        keerad = {
          # Generate only one WSL config; requires a matching Windows user
          nameFunction = _name: "keerad@windex";

          # Standalone configuration independent of the host
          standalone = let
            inherit (inputs) nixpkgs-stable;
            impure = builtins ? currentSystem;
            system =
              if impure
              then builtins.currentSystem
              else throw "Cannot build the
                standalone configuration in pure mode!";
            pkgs = import nixpkgs-stable {inherit system;};
          in {
            enable = impure;
            inherit pkgs;
          };
        };
      };
    };
  };

  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }:
  # Linter setup!
    {
      formatter = config.treefmt.build.wrapper;
      treefmt = {
        inherit (config.flake-root) projectRootFile;
        programs = {
          deadnix.enable = true;
          alejandra.enable = true;
          statix.enable = true;
        };
      };

      pre-commit.settings.hooks = {
        nil.enable = true;
        deadnix.enable = true;
        alejandra.enable = true;
        statix.enable = true;
      };

      devShells.default = withSystem pkgs.stdenv.system (import ./devshell/devshell.nix);
      just-flake.features = withSystem pkgs.stdenv.system (import ./devshell/just-flake.nix);
    }
    # Package derivations
    // {
      packages = lib.mkIf pkgs.stdenv.isLinux {
        disko-install = let wrapped = import ./packages/disko-install.nix {inherit self;}; in withSystem pkgs.stdenv.system wrapped;
      };
    }
    # Runnable app targets!
    // {
      apps =
        {
          bootstrap = withSystem pkgs.stdenv.system (import ./apps/bootstrap.nix);
          devour-flake = let
            wrapped = import ./apps/devour-flake.nix {inherit self inputs;};
          in
            withSystem
            pkgs.stdenv.system
            wrapped;
        }
        // lib.attrsets.mapAttrs (_name: value: {
          type = "app";
          program = lib.getExe value;
        })
        self'.packages;
    }
    # Runnable tests!
    // {
      checks = {
        hello = pkgs.testers.runNixOSTest {
          name = "hello";
          nodes.machine = {pkgs, ...}: {
            environment.systemPackages = [pkgs.hello];
          };
          testScript = ''
            machine.succeed("hello")
          '';
        };
      };
    };

  flake = {
  };
}

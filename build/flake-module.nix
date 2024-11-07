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

    # Module that streamlines tying together system and home configurations.
    ./ez-configs.nix

    # Map a list of valid nixos-generators formats declared by the flake's nixosConfigurations
    # to package derivations that we can directly build.
    ./nixos-generators.nix
  ];

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
      just-flake.features = withSystem pkgs.stdenv.system (import ./devshell/just-flake.nix {
        inherit self;
      });
    }
    # Package derivations
    // {
      packages = lib.mkIf pkgs.stdenv.isLinux {
        disko-install =
          withSystem pkgs.stdenv.system (import ./packages/disko-install.nix {inherit self;});
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

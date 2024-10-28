{
  withSystem,
  self,
  ...
}: _: {
  imports = [
    ./containers
    ./just-flake.nix
  ];

  perSystem = {
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

      devShells.default = withSystem pkgs.stdenv.system (import ./devshell.nix);
    }
    # Package derivations
    // {
      packages = lib.mkIf pkgs.stdenv.isLinux {
        disko-install = let wrapped = import ./packages/disko-install.nix {inherit self;}; in withSystem pkgs.stdenv.system wrapped;
      };
    }
    # Runnable app targets!
    // {
      apps = {
        bootstrap = withSystem pkgs.stdenv.system (import ./apps/bootstrap.nix);
        devour-flake = withSystem pkgs.stdenv.system (import ./apps/devour-flake.nix);
      };
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

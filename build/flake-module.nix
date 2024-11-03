{
  withSystem,
  importApply,
  self,
  inputs,
  ...
}:
# Containers module spans all the options declared below; it is a peer to the flake module.
(importApply ./containers {})
// {
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
      apps = {
        bootstrap = withSystem pkgs.stdenv.system (import ./apps/bootstrap.nix);
        devour-flake = let
          wrapped = import ./apps/devour-flake.nix {inherit self inputs;};
        in
          withSystem
          pkgs.stdenv.system
          wrapped;
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

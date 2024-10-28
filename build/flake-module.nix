{withSystem, ...}: _: {
  imports = [
    ./containers
    ./just-flake.nix
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }:
    {
      # Linter setup!
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

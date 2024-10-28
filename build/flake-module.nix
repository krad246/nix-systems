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
      devShells.default = withSystem pkgs.stdenv.system (import ./devshell.nix);
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
    }
    // {
      apps = {
        bootstrap = withSystem pkgs.stdenv.system (import ./apps/bootstrap.nix);
        devour-flake = withSystem pkgs.stdenv.system (import ./apps/devour-flake.nix);
      };
    }
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

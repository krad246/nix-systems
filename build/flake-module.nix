{
  importApply,
  withSystem,
  self,
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
  ];

  perSystem = {
    inputs',
    config,
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
    // (importApply ./packages {inherit pkgs;})
    // (importApply ./apps {inherit pkgs inputs';})
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
}

# outer / 'flake' scope
{
  importApply,
  self,
  inputs,
  ...
}: let
  apps = import ./apps {inherit importApply self inputs;};

  # Sets up container image packages, custom devShell derivation within the container
  # VSCode *is* supported!
  containers = import ./containers {inherit importApply self;};

  # Module that streamlines tying together system and home configurations.
  ezConfigs = import ./ez-configs {inherit importApply self inputs;};

  devShell = import ./devshell {inherit importApply self;};
  packages = import ./packages {inherit importApply self;};
in {
  # These modules are pretty large but are otherwise structured to merge against
  # the options layers touched below.
  imports = [
    containers.flakeModule
    ezConfigs.flakeModule

    # Map a list of valid nixos-generators formats declared by the flake's nixosConfigurations
    # to package derivations that we can directly build.
    ./nixos-generators.nix

    devShell.flakeModule
    apps.flakeModule
    packages.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }:
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
}

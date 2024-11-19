# outer / 'flake' scope
{
  importApply,
  self,
  inputs,
  ...
}: let
  # standard outputs
  apps = import ./apps {inherit importApply self inputs;};
  devShells = import ./devshell {inherit importApply self;};
  packages = import ./packages {inherit importApply self;};

  # Sets up container image packages, custom devShell derivation within the container
  # VSCode *is* supported!
  containers = import ./containers {inherit importApply self;};

  # Module that streamlines tying together system and home configurations.
  ezConfigs = import ./ez-configs {inherit importApply self inputs;};
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports = [
    apps.flakeModule
    containers.flakeModule
    devShells.flakeModule
    ezConfigs.flakeModule
    packages.flakeModule
  ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      apps = apps.flakeModule;
      containers = containers.flakeModule;
      devShells = devShells.flakeModule;
      ezConfigs = ezConfigs.flakeModule;
      packages = packages.flakeModule;
    };

    modules.flake = flakeModules;
  };

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

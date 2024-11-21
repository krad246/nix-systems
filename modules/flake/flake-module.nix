# outer / 'flake' scope
{
  importApply,
  self,
  inputs,
  ...
}: let
  # standard outputs
  apps = import ./apps {inherit importApply self inputs;};
  devShells = import ./devshell {inherit importApply self inputs;};
  packages = import ./packages {inherit importApply self;};

  # Module that streamlines tying together system and home configurations.
  ez-configs = import ./ez-configs {inherit importApply self inputs;};
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports = [
    apps.flakeModule
    devShells.flakeModule
    ez-configs.flakeModule
    packages.flakeModule
  ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      default = ./.;

      apps = apps.flakeModule;
      devShells = devShells.flakeModule;
      ez-configs = ez-configs.flakeModule;
      packages = packages.flakeModule;
    };

    modules.flake = flakeModules;
  };

  perSystem = {pkgs, ...}: {
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

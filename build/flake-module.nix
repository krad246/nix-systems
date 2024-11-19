# outer / 'flake' scope
{
  importApply,
  self,
  inputs,
  ...
}: let
  devshell = import ./devshell {inherit importApply self;};
  apps = import ./apps {inherit importApply self inputs;};
in {
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

    devshell.flakeModule
    apps.flakeModule
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
    // (import ./packages {inherit self config pkgs;})
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

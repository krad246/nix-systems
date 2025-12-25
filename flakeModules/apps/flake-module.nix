# outer / 'flake' scope
{
  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
    apps =
      {
        bootstrap = let
          runner = pkgs.callPackage ./bootstrap.nix {
            flake-root = config.flake-root.package;
          };
        in {
          type = "app";
          program = lib.meta.getExe runner;
          meta.description = "Run the devShell bootstrap script.";
        };

        fortress-disko-vm = let
          vm = self'.packages.fortress-disko-vm;
        in {
          type = "app";
          program = "${vm}/disko-vm";
          meta.description = "Run a disko-images VM based on the fortress configuration.";
        };
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        fortress-vm = let
          vm = self'.packages.fortress-vm;
        in {
          type = "app";
          program = "${vm}/run-fortress-vm";
          meta.description = "Run a VM based on the fortress configuration.";
        };

        fortress-vm-bootloader = let
          vm = self'.packages.fortress-vm-bootloader;
        in {
          type = "app";
          program = "${vm}/run-fortress-vm";
          meta.description = "Run a VM based on the fortress configuration, with bootloader.";
        };
      };
  };
}

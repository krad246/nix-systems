{
  withSystem,
  inputs,
  self,
  lib,
  ...
}: {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports = with inputs; [
    hercules-ci-effects.flakeModule
  ];

  perSystem = {pkgs, ...}: {
    checks.hello = pkgs.testers.runNixOSTest {
      name = "hello";
      nodes.machine = {pkgs, ...}: {
        environment.systemPackages = [pkgs.hello];
      };
      testScript = ''
        machine.succeed("hello")
      '';
    };
  };

  hercules-ci.flake-update = {
    enable = true;
    autoMergeMethod = "rebase";
    when = {
      hour = [23];
      dayOfWeek = ["Sun"];
    };
  };

  flake = rec {
    effects = _:
      withSystem "x86_64-linux" {
      };

    herculesCI.onPush = {
      default.outputs = {
        inherit (self) apps;
        inherit (self) checks;

        darwinConfigurations = lib.attrsets.mapAttrs (_name: machine: machine.config.system.build.toplevel) self.darwinConfigurations;
        inherit (self) devShells;
        # homeConfigurations = lib.attrsets.mapAttrs (_name: machine: machine.config.specialisation.default.configuration.home.activationPackage) self.homeConfigurations;
        nixosConfigurations = lib.attrsets.mapAttrs (_name: machine: machine.config.system.build.toplevel) self.nixosConfigurations;
        packages =
          lib.attrsets.mapAttrs (
            system: packages: let
              excludesPerSystem = {
                aarch64-linux = packages':
                  lib.attrsets.removeAttrs packages' [
                    "fortress-disko-vm"
                    "fortress-vm"
                    "fortress-sd-aarch64"
                    "fortress-sd-aarch64-installer"
                  ];
                x86_64-linux = packages':
                  lib.attrsets.removeAttrs packages' [
                    "fortress-virtualbox"
                    "fortress-vagrant-virtualbox"
                    "fortress-sd-x86_64"
                    "fortress-vmware"
                  ];
                aarch64-darwin = packages': lib.attrsets.removeAttrs packages' [];
              };

              commonExcludes = lib.attrsets.removeAttrs packages [
                "fortress-hyperv"
                "fortress-iso"
                "fortress-install-iso"
                "fortress-install-iso-hyperv"
                "fortress-qcow"
                "fortress-qcow-efi"
                "fortress-raw"
                "fortress-raw-efi"
                "fortress-vm-bootloader"
              ];
            in
              excludesPerSystem.${system} commonExcludes
          )
          self.packages;
      };
    };
  };
}

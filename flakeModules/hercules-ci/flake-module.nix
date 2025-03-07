{
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

  herculesCI = _herculesCI: {
    onPush = let
      getTopLevelDrv = cfg: cfg.config.system.build.toplevel;
      getDrvs = cfgs: lib.attrsets.mapAttrs (_name: getTopLevelDrv) cfgs;
    in rec {
      default.outputs = lib.modules.mkForce checks.outputs;

      checks.outputs = self.checks;
      darwinConfigurations.outputs = getDrvs self.darwinConfigurations;
      devShells.outputs = self.devShells;
      nixosConfigurations.outputs = getDrvs self.nixosConfigurations;
      packages.outputs = {
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

args @ {
  withSystem,
  self,
  lib,
  ...
}: let
  apps = import ./apps args;
  devShells = import ./devshell args;
  ez-configs = import ./ez-configs args; # ties system and home configurations together
  packages = import ./packages args;
in {
  # the rest of our options perSystem, etc. are set through the flakeModules.
  # keeps code localized per directory
  imports = [
    apps.flakeModule # adds to flake apps
    devShells.flakeModule # adds to flake devShells
    ez-configs.flakeModule # adds to nixosConfigurations, etc.
    packages.flakeModule # adds to packages
  ];

  flake = rec {
    # use these in building other flakes
    flakeModules = {
      default = ./.;

      apps = apps.flakeModule;
      devShells = devShells.flakeModule;
      ez-configs = ez-configs.flakeModule;
      packages = packages.flakeModule;
    };

    # use these for the options namespaces of system / home configurations
    modules = {
      flake = flakeModules; # alias output name

      # ez-configs does the heavy lifting of figuring these out for us

      nixos = self.nixosModules;
      darwin = self.darwinModules;
      home = self.homeModules;

      # can be used in all of the above contexts
      generic = let
        inherit (lib) krad246;
        paths = krad246.fileset.filterExt "nix" ../generic;
      in
        krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path (import path));
    };

    checks = {
      aarch64-linux = withSystem "aarch64-linux" ({pkgs, ...}: {
        hello = pkgs.testers.runNixOSTest {
          name = "hello";
          nodes.machine = {pkgs, ...}: {
            environment.systemPackages = [pkgs.hello];
          };
          testScript = ''
            machine.succeed("hello")
          '';
        };
      });
    };

    herculesCI.onPush = {
      default.outputs = {
        inherit (self) apps;
        inherit (self) checks;

        darwinConfigurations = lib.attrsets.mapAttrs (_name: machine: machine.config.system.build.toplevel) self.darwinConfigurations;
        inherit (self) devShells;
        homeConfigurations = lib.attrsets.mapAttrs (_name: machine: machine.config.specialisation.default.configuration.home.activationPackage) self.homeConfigurations;
        nixosConfigurations = lib.attrsets.mapAttrs (_name: machine: machine.config.system.build.toplevel) self.nixosConfigurations;
        packages =
          lib.attrsets.mapAttrs (
            _system: packages:
              lib.attrsets.removeAttrs packages [
                # "fortress-disko-vm"
                "fortress-hyperv" # aarch64-linux only
                "fortress-install-iso"
                "fortress-install-iso-hyperv"
                "fortress-iso"
                "fortress-qcow"
                "fortress-qcow-efi"
                "fortress-raw"
                "fortress-raw-efi"
                "fortress-sd-aarch64"
                "fortress-sd-aarch64-installer"
                "fortress-sd-x86_64"
                "fortress-vagrant-virtualbox"
                "fortress-virtualbox"
                "fortress-vm"
                "fortress-vmware"
                "fortress-vm-bootloader"
                # "windex-tarball"
              ]
          )
          self.packages;
      };
    };
  };
}

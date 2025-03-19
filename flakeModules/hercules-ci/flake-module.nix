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
      default.outputs = lib.modules.mkForce {
        checks = checks.outputs;
        darwinConfigurations = darwinConfigurations.outputs;
        devShells = devShells.outputs;
        nixosConfigurations = nixosConfigurations.outputs;
        packages = lib.attrsets.mapAttrs (_system: packages:
          lib.attrsets.intersectAttrs packages {
            fortress-disko-vm = 1;
            windex-tarball = 1;
          })
        self.packages;
      };

      checks.outputs = self.checks;
      darwinConfigurations.outputs = getDrvs self.darwinConfigurations;
      devShells.outputs = self.devShells;
      nixosConfigurations.outputs = getDrvs self.nixosConfigurations;
    };
  };
}

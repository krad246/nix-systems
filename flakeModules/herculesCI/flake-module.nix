{
  inputs,
  withSystem,
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

  flake.effects = {
    dullahan-deploy = withSystem "aarch64-darwin" ({hci-effects, ...}:
      hci-effects.runNixDarwin {
        ssh = {
          destination = "root@dullahan.tailb53085.ts.net";
          destinationPkgs = withSystem "aarch64-darwin" (ctx: ctx.pkgs);
          sshOptions = "-o StrictHostKeyChecking=accept-new -oSetEnv=PATH=/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
        };
        secretsMap.ssh = "default-ssh";
        userSetupScript = ''
          writeSSHKey
        '';

        configuration = self.darwinConfigurations.dullahan;
      });

    gremlin-deploy = withSystem "aarch64-darwin" ({hci-effects, ...}:
      hci-effects.runNixDarwin {
        ssh = {
          destination = "root@gremlin.tailb53085.ts.net";
          destinationPkgs = withSystem "aarch64-darwin" (ctx: ctx.pkgs);
          sshOptions = "-o StrictHostKeyChecking=accept-new -oSetEnv=PATH=/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
        };

        secretsMap.ssh = "default-ssh";
        userSetupScript = ''
          writeSSHKey
        '';

        configuration = self.darwinConfigurations.gremlin;
      });

    fortress-deploy = withSystem "aarch64-linux" ({hci-effects, ...}:
      hci-effects.runNixOS {
        ssh = {
          destination = "root@fortress.tailb53085.ts.net";
          destinationPkgs = withSystem "x86_64-linux" (ctx: ctx.pkgs);
          sshOptions = "-o StrictHostKeyChecking=accept-new"; # TODO: convert this to a userSetupScript line for strict host verification
        };

        secretsMap.ssh = "default-ssh";
        userSetupScript = ''
          writeSSHKey
        '';

        config = self.nixosConfigurations.fortress.config.specialisation.ci-agent.configuration;
        system = "x86_64-linux";
      });
  };

  herculesCI = _herculesCI: {
    onSchedule = {
      dullahan-deploy = {
        outputs.effects = {
          inherit (self.effects) dullahan-deploy;
        };
      };

      gremlin-deploy = {
        outputs.effects = {
          inherit (self.effects) gremlin-deploy;
        };
      };

      fortress-deploy = {
        outputs.effects = {
          inherit (self.effects) fortress-deploy;
        };
      };

      fortress-disko-vm = {
        outputs = {
          packages = {
            aarch64-darwin = withSystem "aarch64-darwin" ({self', ...}: {
              inherit (self'.packages) fortress-disko-vm;
            });

            aarch64-linux = withSystem "aarch64-linux" ({self', ...}: {
              inherit (self'.packages) fortress-disko-vm;
            });

            x86_64-linux = withSystem "x86_64-linux" ({self', ...}: {
              inherit (self'.packages) fortress-disko-vm;
            });
          };
        };
      };

      windex-tarball = {
        outputs = {
          packages = {
            aarch64-linux = withSystem "aarch64-linux" ({self', ...}: {
              inherit (self'.packages) windex-tarball;
            });

            x86_64-linux = withSystem "x86_64-linux" ({self', ...}: {
              inherit (self'.packages) windex-tarball;
            });
          };
        };
      };
    };

    onPush = let
      getTopLevelDrv = cfg: cfg.config.system.build.toplevel;
      getDrvs = cfgs: lib.attrsets.mapAttrs (_name: getTopLevelDrv) cfgs;
    in rec {
      checks.outputs = self.checks;
      darwinConfigurations.outputs = getDrvs self.darwinConfigurations;
      devShells.outputs = self.devShells;
      nixosConfigurations.outputs = getDrvs self.nixosConfigurations;
      default.outputs = lib.modules.mkForce {
        checks = checks.outputs;
        darwinConfigurations = darwinConfigurations.outputs;
        devShells = devShells.outputs;
        nixosConfigurations = nixosConfigurations.outputs;
      };
    };
  };
}

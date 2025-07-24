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

  hercules-ci.flake-update = {
    enable = true;
    autoMergeMethod = "rebase";
    when = {
      hour = [23];
      dayOfWeek = ["Sun"];
    };
    effect.system = "aarch64-linux";
  };

  herculesCI = _herculesCI: {
    onPush = rec {
      checks.outputs = self.checks;
      darwinConfigurations.outputs = lib.attrsets.mapAttrs (_name: value: lib.attrsets.dontRecurseIntoAttrs value.system) self.darwinConfigurations;
      devShells.outputs = self.devShells;
      nixosConfigurations.outputs = lib.attrsets.mapAttrs (_name: value: lib.attrsets.dontRecurseIntoAttrs value.config.system.build.toplevel) self.nixosConfigurations;

      default.outputs = lib.modules.mkForce {
        checks = checks.outputs;
        darwinConfigurations = darwinConfigurations.outputs;
        devShells = devShells.outputs;
        nixosConfigurations = nixosConfigurations.outputs;
      };
    };

    onSchedule = {
      dullahan-deploy = {
        outputs.effects = {
          dullahan-deploy = withSystem "aarch64-linux" ({hci-effects, ...}: let
            effect = hci-effects.runNixDarwin {
              ssh = {
                destination = "root@dullahan.tailb53085.ts.net";
                destinationPkgs = withSystem "aarch64-darwin" (ctx: ctx.pkgs);
                sshOptions = "-oSetEnv=PATH=/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
              };
              secretsMap.ssh = "default-ssh";
              userSetupScript = ''
                writeSSHKey

                cat >>~/.ssh/known_hosts <<EOF
                dullahan.tailb53085.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXafRdLT+qPTMUzzMc35PxOP4zun6zIPTf98jQ6Bv5P
                EOF
              '';

              configuration = self.darwinConfigurations.dullahan;
              buildOnDestination = true;
            };

            nohup = effect.overrideAttrs (old: {
              effectScript = let
                pkgs = withSystem "aarch64-darwin" (ctx: ctx.pkgs);
                commands = pkgs.writeShellApplication {
                  name = "nohup-dullahan-deploy";
                  runtimeInputs = [pkgs.coreutils];
                  text = old.effectScript;
                  excludeShellChecks = ["SC2086"];
                };
              in ''
                nohup ${lib.meta.getExe commands}
              '';
            });
          in
            nohup);
        };
      };

      gremlin-deploy = {
        outputs.effects = {
          gremlin-deploy = withSystem "aarch64-linux" ({hci-effects, ...}: let
            effect = hci-effects.runNixDarwin {
              ssh = {
                destination = "root@gremlin.tailb53085.ts.net";
                destinationPkgs = withSystem "aarch64-darwin" (ctx: ctx.pkgs);
                sshOptions = "-oSetEnv=PATH=/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
              };

              secretsMap.ssh = "default-ssh";
              userSetupScript = ''
                writeSSHKey

                cat >>~/.ssh/known_hosts <<EOF
                gremlin.tailb53085.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0IJSgLQ/JomKuYZVV5/ZuboysqBJQCgBcHTvKklQDb
                EOF
              '';

              configuration = self.darwinConfigurations.gremlin;
              buildOnDestination = true;
            };

            nohup = effect.overrideAttrs (old: {
              effectScript = let
                pkgs = withSystem "aarch64-darwin" (ctx: ctx.pkgs);
                commands = pkgs.writeShellApplication {
                  name = "nohup-gremlin-deploy";
                  runtimeInputs = [pkgs.coreutils];
                  text = old.effectScript;
                  excludeShellChecks = ["SC2086"];
                };
              in ''
                nohup ${lib.meta.getExe commands}
              '';
            });
          in
            nohup);
        };
      };

      fortress-deploy = {
        outputs.effects = {
          fortress-deploy = withSystem "x86_64-linux" ({
            hci-effects,
            pkgs,
            ...
          }:
            hci-effects.runNixOS {
              ssh = {
                destination = "root@fortress.tailb53085.ts.net";
                destinationPkgs = pkgs;
                sshOptions = ""; # TODO: convert this to a userSetupScript line for strict host verification
                # buildOnDestination = true;
              };

              secretsMap.ssh = "default-ssh";
              userSetupScript = ''
                writeSSHKey


                cat >>~/.ssh/known_hosts <<EOF
                fortress.tailb53085.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg9s+XAwWrvRf0k16ua9/3tpxbohrTGJEp4rOPnqgOh root@fortress
                EOF
              '';

              config = self.nixosConfigurations.fortress.config.specialisation.ci-agent.configuration;
              system = "x86_64-linux";
            });
        };
      };
    };
  };
}

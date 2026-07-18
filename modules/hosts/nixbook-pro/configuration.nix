{
  config,
  inputs,
  self,
  lib,
  ...
}: {
  flake.darwinConfigurations.nixbook-pro = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      {
        imports = [
          self.modules.darwin.workstation
          self.modules.darwin.tailscale
        ];

        networking.hostName = "nixbook-pro";
        nixpkgs.hostPlatform = "aarch64-darwin";

        nix.linux-builder = {
          enable = true;
          ephemeral = true;
          maxJobs = 60;
          protocol = "ssh-ng";
          systems = lib.trivial.pipe config.systems [
            (lib.trivial.flip lib.lists.forEach lib.systems.parse.mkSystemFromString)
            (lib.lists.filter lib.systems.inspect.predicates.isLinux)
            (lib.trivial.flip lib.lists.forEach lib.systems.parse.doubleFromSystem)
          ];

          config = {
            # This is an ordinary deferred NixOS module. Keep its composition
            # shaped like any other machine even while it remains inline.
            imports = with self.modules.nixos; [
              bottom
              builder
              nix
              swapspace
              terminfo
              zram
            ];

            virtualisation = {
              cores = 8;
              darwin-builder = {
                diskSize = 64 * 1024;
                memorySize = 16 * 1024;
              };
            };

            systemd.coredump.enable = false;

            swapDevices = lib.mkOverride 9 [
              {
                device = "/swapfile";
                size = 16 * 1024;
              }
            ];
          };
        };
      }
      (
        {config, ...}: {
          users.users.${config.owner.username} = {
            uid = 501;
            gid = 20;
          };
        }
      )
      (
        {
          config,
          pkgs,
          ...
        }: {
          programs.bash.enable = true;
          users.users.${config.owner.username}.shell = pkgs.bashInteractive;
        }
      )
      (
        {config, ...}: {
          networking = {
            localHostName = config.networking.hostName;
            computerName = config.networking.hostName;

            knownNetworkServices = ["Wi-Fi"];

            dns = [
              "1.1.1.1"
              "1.0.0.1"
              "2606:4700:4700::1111"
              "2606:4700:4700::1001"

              "8.8.8.8"
              "8.8.4.4"
              "2001:4860:4860::8888"
              "2001:4860:4860::8844"
            ];
          };
        }
      )
      {
        environment.variables.NIX_REMOTE = "daemon";

        nix.settings = {
          auto-allocate-uids = false;
          auto-optimise-store = false;
          extra-sandbox-paths = ["/nix/store"];
        };
      }
      {
        nix.settings = {
          keep-derivations = true;
          max-substitution-jobs = 60;
        };
      }
      (
        {config, ...}: {
          nix.settings.trusted-users = [config.owner.username];
        }
      )
      {
        security.pam.services.sudo_local.touchIdAuth = true;
      }
      {
        system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      }
    ];
  };
}

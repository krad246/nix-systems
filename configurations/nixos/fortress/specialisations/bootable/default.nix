args @ {
  importApply,
  self,
  ...
}: let
  shared = {
    imports =
      # device-specific provisioning
      [
        (importApply ./efiboot.nix args)
        (importApply ./hardware-configuration.nix args)
        (importApply ./authorized-keys.nix args)
      ]
      ++ [
        self.diskoConfigurations.fortress-desktop
      ]
      # remote access is shared for these bootable specializations
      ++ [self.nixosModules.avahi];

    # Holds up boot pointlessly
    systemd.services.NetworkManager-wait-online.enable = false;

    # Prefer to idle in LPM only when explicitly requested
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=yes
      AllowHybridSleep=yes
      AllowSuspendThenHibernate=yes
    '';
  };
in rec {
  fortress = desktop;

  desktop.configuration = _: {
    imports =
      [shared]
      ++ [
        ./desktop/configuration.nix
      ];
  };

  ci-agent.configuration = _: {
    imports =
      [shared]
      ++ [
        ./ci-agent/agenix.nix
        ./ci-agent/cachix-agent.nix
        ./ci-agent/hercules-ci-agent.nix
      ];

    nix.settings.max-substitution-jobs = 144;

    virtualisation = {
      docker.enable = true;
      containerd.enable = true;
    };

    users.users.krad246.extraGroups = ["docker"];
  };
}

let
  shared = {self, ...}: {
    imports =
      [
        ./authorized-keys.nix
        ./avahi.nix
        ./efiboot.nix
        ./hardware-configuration.nix
        ./sshd.nix
      ]
      ++ [
        self.diskoConfigurations.fortress-desktop
        self.nixosModules.base-configuration
      ];

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

    # large tmpfs for CI builds
    boot.tmp.tmpfsSize = "176G";
  };
}

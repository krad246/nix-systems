let
  shared = {self, ...}: {
    imports =
      [
        ./avahi.nix
        ./efiboot.nix
        ./hardware-configuration.nix
        ./sshd.nix
      ]
      ++ [
        self.diskoConfigurations.fortress-desktop
        self.nixosModules.base-configuration
      ];

    services.tailscale = {
      enable = true;
      extraUpFlags = ["--ssh"];
    };

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

  ci-agent.configuration = {...}: {
    imports =
      [shared]
      ++ [
        ./ci-agent/agenix.nix
        ./ci-agent/cachix-agent.nix
        ./ci-agent/hercules-ci-agent.nix
      ];

    nix = {
      settings.max-substitution-jobs = 144;
      # daemonIOSchedClass = lib.mkDefault "idle";
      # daemonCPUSchedPolicy = lib.mkDefault "idle";
    };

    # put the service in top-level slice
    # so that it's lower than system and user slice overall
    # instead of only bing lower in system slice
    # systemd.services.nix-daemon.serviceConfig.Slice = "-.slice";

    # build and evaluation jobs are ALWAYS pushed to the daemon, so that no locking is required.
    # improves 'streaming job' performance (?)
    environment.variables.NIX_REMOTE = "daemon";

    virtualisation = {
      docker.enable = true;
      containerd.enable = true;
    };

    users.users.krad246.extraGroups = ["docker"];

    # large tmpfs for CI builds
    boot.tmp.tmpfsSize = "176G";
  };
}

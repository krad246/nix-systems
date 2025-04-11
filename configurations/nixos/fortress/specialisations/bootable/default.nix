{
  # Gaming desktop configuration
  desktop.configuration = _: {
    imports =
      [./base-configuration.nix]
      ++ [
        ./desktop/configuration.nix
      ];
  };

  # always-on CI agent configuration
  ci-agent.configuration = {...}: {
    imports =
      [./base-configuration.nix]
      ++ [
        ./ci-agent/cachix-agent.nix
        ./ci-agent/container.nix
        ./ci-agent/hercules-ci-agent.nix
      ];

    # Prefer to idle in LPM only when explicitly requested
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=yes
      AllowHybridSleep=yes
      AllowSuspendThenHibernate=yes
    '';

    nix = {
      settings.max-substitution-jobs = 144;
    };

    # large tmpfs for CI builds
    boot.tmp.tmpfsSize = "176G";

    # Use the host key actually stored to persistent storage rather than the one that gets dynamically mounted
    # This allows for the first activation to automatically unlock our secrets.
    age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];
  };
}

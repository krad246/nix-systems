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
        ./ci-agent/agenix.nix
        ./ci-agent/cachix-agent.nix
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

    # run in multi-user mode always
    environment.variables.NIX_REMOTE = "daemon";

    # large tmpfs for CI builds
    boot.tmp.tmpfsSize = "176G";
  };
}

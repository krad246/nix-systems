{
  inputs,
  self,
  config,
  ...
}: {
  # essentially, systemd-nspawn containers are plugged into the 'externalInterface'
  # through virtual ethernet cables, the 'internalInterfaces', and container networks are
  # behind a NAT. this way they can run their own distinct networking configurations.
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "wlp11s0";
    enableIPv6 = true;
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  containers.hercules-ci-agent = {
    autoStart = true;
    privateNetwork = true;

    bindMounts = {
      "${config.services.hercules-ci-agent.settings.staticSecretsDirectory}" = {
        hostPath = config.age.secretsDir + "/hercules-ci";
        isReadOnly = true;
      };
    };

    config = {
      imports = [
        inputs.hercules-ci-agent.nixosModules.agent-profile
        self.modules.generic.hercules-ci-agent
      ];

      services.hercules-ci-agent.enable = true;

      networking.useHostResolvConf = false;
      services.resolved.enable = true;
    };

    extraFlags = [
      # "--bind-user=hercules-ci-agent"
      "-U"
    ];
  };
}

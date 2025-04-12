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

    # TODO: set up DNS, etc. here
    # privateNetwork = true;

    config = {
      imports = [
        inputs.hercules-ci-agent.nixosModules.agent-profile
        self.modules.generic.hercules-ci-agent
      ];

      services.hercules-ci-agent.enable = true;
      boot.binfmt.emulatedSystems = ["aarch64-linux"];
    };

    # TODO: need to automatically chown the mounted directory at container spawn time
    extraFlags = [
      "--overlay=${config.age.secretsDir + "/hercules-ci"}:${config.services.hercules-ci-agent.settings.staticSecretsDirectory}"
      # "-U" # TODO: can't seem to log into hercules CI in a private user namespace
    ];
  };
}

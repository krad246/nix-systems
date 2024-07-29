{
  nix = {
    settings.trusted-users = ["@admin"];
    linux-builder = {
      enable = true;
      config = {
        config,
        lib,
        ...
      }: {
        boot.binfmt.emulatedSystems = ["i686-linux" "x86_64-linux"];
        nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
        virtualisation = {
          diskSize = lib.mkForce 65536;
          memorySize = lib.mkForce 8192;
        };
      };
      mandatoryFeatures = [];
      supportedFeatures = ["big-parallel"];
      maxJobs = 16;
      protocol = "ssh-ng";
      ephemeral = true;
      systems = ["i686-linux" "x86_64-linux" "aarch64-linux"];
    };
  };
}

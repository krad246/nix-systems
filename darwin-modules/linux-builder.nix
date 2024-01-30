{
  nix = {
    settings.trusted-users = ["@admin"];
    linux-builder = {
      enable = true;
      config = {config, ...}: {
        boot.binfmt.emulatedSystems = ["i686-linux" "x86_64-linux"];
        nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
      };
      mandatoryFeatures = [];
      supportedFeatures = ["big-parallel"];
      maxJobs = 1;
      systems = ["x86_64-linux" "aarch64-linux"];
    };
  };
}

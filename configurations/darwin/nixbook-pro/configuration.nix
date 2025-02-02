{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    base-configuration
  ];

  krad246.darwin = {
    # Used in conjunction with single-user settings.
    # Wraps users.users option
    masterUser = {
      enable = true;
      owner = rec {
        name = "krad246";
        home = "/Users/${name}";

        uid = 501;
        gid = 20;

        shell = "${config.homebrew.brewPrefix}/bash";
        createHome = true;
      };
    };

    virtualisation = rec {
      # Configure onboard nix-builder VM specs
      linux-builder = {
        enable = true;
        ephemeral = true;
        maxJobs = 60;
        cores = 8;
        memorySize = 16 * 1024;
        diskSize = 192 * 1024;
        swapSize = 32 * 1024;
      };
    };
  };

  # Enable more deep caching of artifacts since we have space
  nix = {
    settings = {
      keep-derivations = true;
      max-substitution-jobs = 60;
    };
  };

  ids.gids.nixbld = 350;
}

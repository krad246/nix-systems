{
  self,
  config,
  lib,
  ...
}: {
  imports = with self.darwinModules; [
    apps
    base-configuration
    tailscale
  ];

  system.defaults.dock.persistent-apps = lib.modules.mkBefore ["/Applications/Zen.app"];

  krad246.darwin = {
    apps = {
      arc = false;
      launchcontrol = false;
    };

    # Used in conjunction with single-user settings.
    # Wraps users.users option
    masterUser = {
      enable = true;
      owner = rec {
        name = "krad246";
        home = "/Users/${name}";

        uid = 501;
        gid = 20;

        shell = "${config.homebrew.prefix}/bin/bash";
        createHome = true;
      };
    };

    virtualisation = {
      # Configure onboard nix-builder VM specs
      linux-builder = {
        enable = true;
        ephemeral = true;
        maxJobs = 60;
        cores = 8;
        memorySize = 16 * 1024;
        diskSize = 96 * 1024;
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

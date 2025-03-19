{
  self,
  config,
  ...
}: {
  imports =
    (with self.darwinModules; [
      apps
      base-configuration
      sshd
      tailscale
      wake-on-lan
    ])
    ++ (with self.modules.generic; [fortress]);

  # corrects a MacOS Sequoia change to the UID space
  ids.gids.nixbld = 30000;

  # my custom overrides over the base-configuration module.
  krad246 = {
    darwin = {
      apps = {
        arc = false;
        bluesnooze = false;
        groupme = false;
        launchcontrol = false;
        magnet = false;
        signal = false;
        utm = true;
        zen-browser = false;
        zoom = false;
      };

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

      virtualisation.linux-builder = {
        ephemeral = false;

        memorySize = 8 * 1024;
        diskSize = 128 * 1024;

        maxJobs = 32;
        cores = 8;

        systems = ["aarch64-linux" "x86_64-linux"];
      };
    };

    remotes.fortress = {
      enable = true;
      sshUser = "krad246";
      sshKey = config.age.secrets.id_ed25519_priv.path;
      maxJobs = 72;
      speedFactor = 3;
    };
  };
}

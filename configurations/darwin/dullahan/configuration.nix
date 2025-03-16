{
  specialArgs,
  self,
  config,
  lib,
  ...
}: {
  imports = with self.darwinModules; [
    apps
    base-configuration
    sshd
    tailscale
    wake-on-lan
  ];

  # restrict SSH access to known host keys
  users.users.krad246.openssh.authorizedKeys.keys = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "pub" ./authorized_keys;
  in
    lib.lists.forEach paths (path: builtins.readFile path);

  # corrects a MacOS Sequoia change to the UID space
  ids.gids.nixbld = 30000;

  # my custom overrides over the base-configuration module.
  krad246.darwin = {
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

    linux-builder = {
      ephemeral = false;

      memorySize = 8 * 1024;
      diskSize = 128 * 1024;

      maxJobs = 32;
      cores = 8;

      systems = ["aarch64-linux" "x86_64-linux"];
    };
  };
}

{
  self,
  specialArgs,
  lib,
  ...
}: {
  krad246.darwin.virtualisation.linux-builder = {
    ephemeral = false;

    extraConfig = {config, ...}: {
      imports = [self.nixosModules.agenix];

      services.hercules-ci-agent = {
        enable = true;
        settings = {
          clusterJoinTokenPath = config.age.secrets.headless-penguin-cluster-join-token.path;
          binaryCachesPath = config.age.secrets.headless-penguin-binary-caches.path;
          concurrentTasks = 12;
        };
      };

      # pull all .age files and give them to the CI agent
      age.secrets = let
        inherit (specialArgs) krad246;
        paths = krad246.fileset.filterExt "age" ../secrets/system;
      in
        krad246.attrsets.genAttrs' paths (path:
          krad246.attrsets.stemValuePair path {
            file = path;
            mode = "770";
            group = "hercules-ci-agent";
          });

      # enable remote SSH connections into the builder for other machines
      users.users.builder = {
        extraGroups = ["systemd-journal"];
        openssh.authorizedKeys.keys = let
          inherit (specialArgs) krad246;
          paths = krad246.fileset.filterExt "pub" ../authorized_keys;
        in
          lib.lists.forEach paths (path: builtins.readFile path);
      };
    };

    maxJobs = 24;
    cores = 8;
    systems = ["aarch64-linux"];
  };
}

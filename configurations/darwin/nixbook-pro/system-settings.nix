{
  self,
  specialArgs,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    base-configuration
    colima
  ];

  # Parse the secrets directory
  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ./secrets;
  in
    krad246.attrsets.genAttrs' paths (path:
      krad246.attrsets.stemValuePair path {
        file = path;
      });

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
      };

      colima = {
        enable = true;
        inherit (linux-builder) memorySize;
        inherit (linux-builder) cores;
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

  # enable Lorri daemon for nix-direnv
  services.lorri.enable = true;
}

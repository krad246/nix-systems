{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) modules;
in {
  nix = {
    package = modules.mkDefault pkgs.nixVersions.stable;
    checkConfig = true;
    gc.automatic = true;
    settings =
      {
        experimental-features =
          ["nix-command" "flakes"]
          ++ [
            "auto-allocate-uids"
          ]
          ++ (lib.lists.optionals pkgs.stdenv.isLinux [
            "cgroups"
          ]);

        # UID, resource, and mount containerization options
        # Dynamically create and destroy users if possible. If not, run builds in the Nix daemon users.
        # These users shall run builds in a chroot, where the filesystem is virtualized.
        # Enable mapping of daemon processes to CGroups, so that builds can be tuned.
        auto-allocate-uids = modules.mkDefault true;
        build-users-group = "nixbld";
        sandbox = modules.mkForce true;
        sandbox-fallback = modules.mkForce true;
        # use-cgroups = pkgs.stdenv.isLinux;

        # Performance tuning, scale automatically to the number of processors.
        # Considering that most computers don't have 16 CPUs, this means that we'd have typically at least 2 substitution jobs running on each core.
        cores = 0;
        max-jobs = "auto";
        max-substitution-jobs = modules.mkDefault 32;

        # Force filesystem syncs on builds.
        # Most useful for CI agents, where power failure and system crashes may result in corruption of files.
        # Also, prefer to allocate the full extent of a file when building an output.
        # This allows us to catch disk space exhaustion issues.
        fsync-metadata = true;
        # fsync-store-paths = true;
        preallocate-contents = true;
        sync-before-registering = true;

        # Store deduplication and garbage collection rules.
        # Prefer to keep as many outputs as possible and build for as long as possible before terminating due to errors.
        # Try to deduplicate whenever possible to optimize storage space.
        auto-optimise-store = modules.mkDefault true;
        keep-build-log = true;
        keep-derivations = true;
        keep-env-derivations = true;
        keep-failed = false;
        keep-going = modules.mkDefault true;
        keep-outputs = modules.mkDefault true;
        min-free = modules.mkDefault "8G";

        # Prefer to pull as many outputs from binary caches as possible.
        builders-use-substitutes = true;
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://krad246.cachix.org"
        ];

        trusted-substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://krad246.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "krad246.cachix.org-1:N57J9SfNFtxMSYnlULH4l7ZkdNjIQb0ByyapaEb/8IM="
        ];

        # How long to wait before declaring a build as failed.
        connect-timeout = modules.mkDefault 300;
        timeout = modules.mkDefault 3600;
        max-silent-time = modules.mkDefault 3600;

        # Store Nix user environment pointers in each user's home directory.
        use-xdg-base-directories = true;
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        use-cgroups = true;
      };
  };
}

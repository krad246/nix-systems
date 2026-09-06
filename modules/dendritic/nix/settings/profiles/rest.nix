{
  flake.modules = {
    generic.nix = {
      # nix.settings = {
      #   # Multi-user daemon policy.
      #   # Keep the builder pool explicit across platforms.
      #   build-users-group = "nixbld";

      #   # Keep daemon privilege narrow: only root is trusted.
      #   # Trusted users can perform operations equivalent to root.
      #   trusted-users = ["root"];

      #   # Performance tuning.
      #   max-jobs = "auto";
      #   max-substitution-jobs = lib.modules.mkDefault 32;
      #   download-buffer-size = lib.modules.mkDefault (1024 * 1024 * 1024);

      #   # Force filesystem syncs on builds.
      #   # Most useful for CI agents, where power failure and system crashes may result in corruption of files.
      #   # Also, prefer to allocate the full extent of a file when building an output.
      #   # This allows us to catch disk space exhaustion issues.
      #   preallocate-contents = true;
      #   sync-before-registering = true;

      #   # Prefer to keep as many outputs as possible and build for as long as possible before terminating due to errors.
      #   keep-env-derivations = true;
      #   keep-failed = true;
      #   keep-going = lib.modules.mkDefault true;
      #   keep-outputs = lib.modules.mkDefault true;

      #   # Prevent the Nix Store from completely exhausting the disk.
      #   min-free = lib.modules.mkDefault "16G";

      #   # Prefer to pull as many outputs from binary caches as possible.
      #   builders-use-substitutes = true;
      #   trusted-substituters = [
      #     "https://cache.nixos.org"
      #     "https://nix-community.cachix.org"
      #   ];

      #   # How long to wait before declaring a build as failed.
      #   connect-timeout = lib.modules.mkDefault 300;
      #   timeout = lib.modules.mkDefault 3600;
      #   max-silent-time = lib.modules.mkDefault 3600;

      # };
    };

    darwin.nix = {
      # nix = {
      #   daemonIOLowPriority = lib.modules.mkDefault true;
      #   daemonProcessType = lib.modules.mkDefault "Adaptive";

      #   settings = {
      #     auto-allocate-uids = false;
      #     auto-optimise-store = false;

      #     extra-sandbox-paths = ["/nix/store"];
      #   };
      # };
    };

    nixos.nix = {
      # nix.settings = {
      #   extra-experimental-features = [
      #     "auto-allocate-uids"
      #     "cgroups"
      #   ];

      #   auto-allocate-uids = lib.modules.mkDefault true;
      #   auto-optimise-store = lib.modules.mkDefault true;

      #   use-cgroups = true;
      # };
    };
  };
}

{
  config,
  lib,
  ...
}: {
  nix = {
    settings.trusted-users = ["@admin"];

    linux-builder = {
      enable = true;

      # Start with an empty configuration - impure builds (which add additional functionality)
      # can only run once there is an initial pure generation of the Linux builder.
      config = args @ {pkgs, ...}: let
        inherit (pkgs.stdenv) system;
        inherit (config.nix) linux-builder;
      in
        lib.attrsets.optionalAttrs (!lib.trivial.inPureEvalMode) {
          # Emulate all of the linux-builder systems aside from the host platform of the builder
          # because it makes no sense.
          boot.binfmt.emulatedSystems = lib.lists.remove system linux-builder.systems;

          virtualisation = {
            darwin-builder = {
              diskSize = 1024 * 96;
              memorySize = 1024 * 6;
            };

            cores = 6;
          };

          programs.ccache.enable = true;

          nixpkgs.overlays = [
            (_self: super: {
              ccacheWrapper = super.ccacheWrapper.override {
                extraConfig = ''
                  export CCACHE_COMPRESS=1
                  export CCACHE_DIR="${args.config.programs.ccache.cacheDir}"
                  export CCACHE_UMASK=007
                  if [ ! -d "$CCACHE_DIR" ]; then
                    echo "====="
                    echo "Directory '$CCACHE_DIR' does not exist"
                    echo "Please create it with:"
                    echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
                    echo "  sudo chown root:nixbld '$CCACHE_DIR'"
                    echo "====="
                    exit 1
                  fi
                  if [ ! -w "$CCACHE_DIR" ]; then
                    echo "====="
                    echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
                    echo "Please verify its access permissions"
                    echo "====="
                    exit 1
                  fi
                '';
              };
            })
          ];

          nix.settings.extra-sandbox-paths = [args.config.programs.ccache.cacheDir];

          # Give the builder all of our substituters.
          nix.settings = {
            inherit (config.nix.settings) substituters trusted-substituters trusted-public-keys;
          };
        };

      maxJobs = 16;
      protocol = "ssh-ng";
      ephemeral = true; # NOTE: seems to be mandatory for deterministic Darwin builds.
      systems = ["i386-linux" "i686-linux" "x86_64-linux" "aarch64-linux"];
    };
  };

  homebrew.casks = ["docker"];
}

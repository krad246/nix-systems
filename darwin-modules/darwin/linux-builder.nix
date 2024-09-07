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
      config = {pkgs, ...}: let
        inherit (pkgs.stdenv) system;
        inherit (config.nix) linux-builder;
      in
        lib.attrsets.optionalAttrs (!lib.trivial.inPureEvalMode) {
          imports = [./ccache-stdenv.nix];

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

  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };
}

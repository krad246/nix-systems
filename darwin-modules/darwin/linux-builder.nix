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
          # Emulate all of the linux-builder systems aside from the host platform of the builder
          # because it makes no sense.
          boot.binfmt.emulatedSystems = lib.lists.remove system linux-builder.systems;
          virtualisation.darwin-builder = {
            diskSize = 1024 * 96;
            memorySize = 1024 * 6;
          };

          programs.ccache.enable = true;

          # Give the builder all of our substituters.
          nix.settings = {
            inherit (config.nix.settings) substituters trusted-substituters trusted-public-keys;
          };
        };

      maxJobs = 16;
      protocol = "ssh-ng";
      ephemeral = true;
      systems = ["i386-linux" "i686-linux" "x86_64-linux" "aarch64-linux" "riscv32-linux" "riscv64-linux"];
    };
  };
}

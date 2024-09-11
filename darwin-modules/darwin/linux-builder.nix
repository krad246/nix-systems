{
  config,
  lib,
  ...
}: {
  nix = {
    settings.trusted-users = ["@admin" "@wheel"];

    linux-builder = {
      enable = true;

      # Start with an empty configuration - impure builds (which add additional functionality)
      # can only run once there is an initial pure generation of the Linux builder.
      config = {pkgs, ...}: let
        inherit (pkgs.stdenv) system;
        inherit (config.nix) linux-builder;
      in
        {
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

          # TODO: replace with age secret
          users.users.builder.openssh.authorizedKeys.keys =
            [
              # builder@linux-builder@nixbook-air
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv7KwgQc5URwPWHFKAL7WIVBHqOlNBaznUfgUFrOtut builder@localhost"

              # builder@linux-builder@dullahan
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEcGy0gw1QAXOQKaDd7f2hC3tMfew9ZDijyNwJqQ6GAW builder@localhost"
            ]
            ++ [
              # krad246@nixbook-air
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"

              # krad246@dullahan
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzCjoarVDF5bnWX3SBciYyaiMzGnzTF9uefbja5xLB0"
            ];
        };

      maxJobs = 16;
      protocol = "ssh-ng";
      ephemeral = true; # NOTE: seems to be mandatory for deterministic Darwin builds.
      systems = ["i386-linux" "i686-linux" "x86_64-linux" "aarch64-linux"];
    };
  };

  homebrew.casks = ["docker"];
}

{
  self,
  lib,
  ...
}: {
  flake.modules.darwin.linux-builder = {config, ...}: let
    cfg = config.remoteBuilder;
    backend = cfg.backends.linux-builder;
  in {
    imports = [self.modules.darwin.remote-builder];

    options.remoteBuilder.backends.linux-builder = {
      enable = lib.options.mkEnableOption "nix-darwin linux-builder backend";
      ephemeral = lib.options.mkEnableOption "ephemeral linux-builder VM";
    };

    config = lib.modules.mkIf backend.enable {
      nix.linux-builder = {
        enable = true;
        inherit (backend) ephemeral;
        inherit (cfg) maxJobs systems;
        protocol = "ssh-ng";

        config.imports = [
          self.modules.nixos.remote-builder
          cfg.configuration
        ];
      };
    };
  };
}

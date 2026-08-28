# outer / 'flake' scope
{
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    apps = {
      agent-checkpoint = {
        type = "app";
        program = lib.meta.getExe (pkgs.callPackage ./agent-checkpoint.nix {
          flake-root = config.flake-root.package;
        });
        meta.description = "Checkpoint active agent-maintained context.";
      };

      bootstrap = let
        runner = pkgs.callPackage ./bootstrap.nix {
          flake-root = config.flake-root.package;
        };
      in {
        type = "app";
        program = lib.meta.getExe runner;
        meta.description = "Run the devShell bootstrap script.";
      };

      # FIXME(fortress-images): Restore with the generator projection backend.
      # fortress-disko-vm = let
      #   vm = self'.packages.fortress-disko-vm;
      # in {
      #   type = "app";
      #   program = "${vm}/disko-vm";
      #   meta.description = "Run a disko-images VM based on the fortress configuration.";
      # };
    };

    # FIXME(fortress-images): Legacy Fortress VM apps are temporarily omitted.
    # Their package projections still force known-broken legacy NixOS and IFD
    # paths during CI. Restore them through dendritic.configurations images.
  };
}

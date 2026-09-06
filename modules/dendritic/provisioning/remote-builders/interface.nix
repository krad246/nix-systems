{
  config,
  lib,
  ...
}: {
  flake.modules.darwin.remote-builder = {
    options.remoteBuilder = {
      configuration = lib.options.mkOption {
        type = lib.types.deferredModule;
        default = {};
        description = "NixOS module describing the remote build machine.";
      };

      maxJobs = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 24;
        description = "Maximum concurrent jobs assigned to the remote builder.";
      };

      systems = lib.options.mkOption {
        type = lib.types.listOf lib.types.str;
        default = lib.trivial.pipe config.systems [
          (lib.trivial.flip lib.lists.forEach lib.systems.parse.mkSystemFromString)
          (lib.lists.filter lib.systems.inspect.predicates.isLinux)
          (lib.trivial.flip lib.lists.forEach lib.systems.parse.doubleFromSystem)
        ];
        description = "Nix systems advertised by the remote builder.";
      };
    };
  };
}

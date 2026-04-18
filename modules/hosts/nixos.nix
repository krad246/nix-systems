{lib, ...}: {
  options.flake.hosts.nixos = lib.options.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          modules = lib.options.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
          };
        };
      }
    );

    default = {};
  };
}

{
  flake.modules.generic.input-registry = {
    config,
    lib,
    ...
  }: let
    cfg = config.input-registry;
  in {
    options.input-registry.search-path = {
      enable = lib.options.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to set the legacy Nix search path NIX_PATH to point to the input registry sysroot.";
      };
    };

    config = {
      assertions = [
        {
          assertion = cfg.search-path.enable -> cfg.sysroot.install;
          message = ''
            Setting the input registry as the legacy Nix search path requires installing a view of those inputs into the filesystem.
          '';
        }
      ];

      nix.nixPath = lib.modules.mkIf cfg.search-path.enable [
        cfg.sysroot.abspath
      ];
    };
  };
}

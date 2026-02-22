{inputs, ...}: {
  flake.modules.generic.input-registry = ctx @ {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.input-registry.registry;
  in {
    options.input-registry = {
      registry = {
        managed = lib.options.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the input registry aspect, providing a configurable flake registry with optional filesystem projection and legacy NIX_PATH compatibility.";
        };

        source =
          options.nix.registry
          // {
            default = let
              isFlake = _: lib.types.isType "flake";
              toEntry = _: flake: {inherit flake;};
            in
              lib.trivial.pipe inputs [
                (lib.attrsets.filterAttrs isFlake)
                (lib.attrsets.mapAttrs toEntry)
              ];

            readOnly = cfg.locked;
          };

        locked = lib.options.mkOption {
          type = lib.types.bool;
          internal = true;
          default = !(ctx ? osConfig); # TODO: figure out if this is safe on freestanding HM configs
          readOnly = true;
        };
      };
    };

    config = lib.modules.mkIf cfg.managed {
      nix = {
        registry = cfg.source;
        settings.experimental-features = ["nix-command" "flakes"];
      };
    };
  };
}

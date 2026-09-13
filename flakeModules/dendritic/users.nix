{
  lib,
  types,
  ...
}: let
  inherit (types) moduleContributions variantType;
in {
  options.dendritic.configurations.users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      imports = [moduleContributions];

      options = {
        enable = lib.mkEnableOption "this Home Manager user";
        tags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Ordered profile aspects selecting contributions for this user node.";
        };
        standalone = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule {
            imports = [moduleContributions];
            options = {
              pkgs = lib.mkOption {
                type = lib.types.pkgs;
                description = "Package set used to evaluate this standalone Home Manager configuration.";
              };
              outputName = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Optional name for this standalone Home Manager root.";
              };
            };
          });
          default = null;
          description = "Optional standalone Home Manager output for this user; presence enables the output.";
        };
        passInOsConfig = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether host-derived configurations receive osConfig.";
        };
        variants = lib.mkOption {
          type = lib.types.attrsOf variantType;
          default = {};
          description = "Sparse Home Manager variant coordinates.";
        };
      };
    });
    default = {};
    description = "Home Manager users forming one axis of the configuration matrix.";
  };
}

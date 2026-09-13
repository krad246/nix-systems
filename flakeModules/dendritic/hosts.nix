{
  lib,
  types,
  ...
}: let
  inherit (types) hostUsers moduleContributions platformType variantType;
in {
  options.dendritic.configurations = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        imports = [moduleContributions hostUsers];
        options = {
          enable = lib.mkEnableOption "this NixOS or nix-darwin host";
          outputName = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Optional name for this host's root system output.";
          };
          tags = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Ordered profile aspects selecting the corresponding perTag.<name> overlays.";
          };
          metadata = lib.mkOption {
            type = lib.types.attrsOf lib.types.raw;
            default = {};
            description = "Machine facts and annotations carried with this host declaration.";
          };
          hostPlatforms = lib.mkOption {
            type = lib.types.listOf platformType;
            default = [];
            description = "Constraints describing every realizable destination host platform.";
          };
          variants = lib.mkOption {
            type = lib.types.attrsOf variantType;
            default = {};
            description = "Sparse system variant and specialisation coordinates.";
          };
        };
      });
      default = {};
      description = "System hosts forming one axis of the configuration matrix.";
    };
  };
}

{
  lib,
  types,
  ...
}: let
  inherit (types) argumentOption compositionType;
in {
  options.dendritic.configurations = {
    globalArgs = argumentOption "Target-independent early arguments shared by every native and Home Manager evaluator.";
    earlyModuleArgs = argumentOption "Target-independent early module arguments shared by every composed evaluator.";
    lateModuleArgs = argumentOption "Late arguments shared through _module.args by every composed evaluator.";
    defaults = lib.mkOption {
      type = lib.types.submodule {
        options = {
          tags = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Ordered profile aspects inherited by every host and user declaration.";
          };
          variants = {
            enableFlakeOutputs = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether variants materialize as independent flake outputs by default.";
            };
            enable = lib.mkEnableOption "independent variant outputs";
            includeSpecialisations = lib.mkEnableOption "variants in native specialisation sets by default";
            nameFunction = lib.mkOption {
              type = lib.types.functionTo lib.types.str;
              default = coordinates:
                if coordinates ? package
                then "${coordinates.host}-${coordinates.package}-${coordinates.hostPlatform}"
                else if coordinates ? user && coordinates ? host
                then "${coordinates.user}-${coordinates.host}"
                else if coordinates ? host && coordinates ? variant
                then "${coordinates.host}-${coordinates.variant}"
                else if coordinates ? user && coordinates ? variant
                then "${coordinates.user}-${coordinates.variant}"
                else coordinates.name or "dendritic";
              defaultText = lib.literalExpression "coordinates: if coordinates ? package then \"\${coordinates.host}-\${coordinates.package}-\${coordinates.hostPlatform}\" else if coordinates ? user && coordinates ? host then \"\${coordinates.user}-\${coordinates.host}\" else if coordinates ? host && coordinates ? variant then \"\${coordinates.host}-\${coordinates.variant}\" else if coordinates ? user && coordinates ? variant then \"\${coordinates.user}-\${coordinates.variant}\" else coordinates.name or \"dendritic\"";
              description = "Compatibility-only legacy naming hook; output names now belong to the typed host, user, and variant nodes.";
            };
          };
        };
      };
      default = {};
      description = "Inherited profile and variant-output defaults.";
    };
    shared = lib.mkOption {
      type = compositionType;
      default = {};
      description = "Modules shared by every host.";
    };
    perSystem = lib.mkOption {
      type = lib.types.attrsOf compositionType;
      default = {};
      description = "Modules selected by host platform system.";
    };
    perArch = lib.mkOption {
      type = lib.types.attrsOf compositionType;
      default = {};
      description = "Modules selected by the architecture component of a host platform.";
    };
    perTag = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          perClass = lib.mkOption {
            type = lib.types.attrsOf compositionType;
            default = {};
            description = "Class-specific module contributions selected when this profile aspect is active.";
          };
          meta = lib.mkOption {
            type = lib.types.attrsOf lib.types.raw;
            default = {};
            description = "Descriptive metadata carried by this profile aspect.";
          };
          passthru = lib.mkOption {
            type = lib.types.attrsOf lib.types.raw;
            default = {};
            description = "Arbitrary declarative data passed through with this profile aspect.";
          };
        };
      });
      default = {};
      description = "Canonical profile aspects, each with class-specific contributions shaped like perClass.";
    };
  };
}

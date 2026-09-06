{lib, ...}: {
  flake.modules.darwin.app-store = {config, ...}: let
    cfg = config.appStore;

    variantType = lib.types.submodule {
      freeformType = lib.types.attrsOf lib.types.anything;
    };

    selections = lib.attrsets.mapAttrs (application: variants:
      cfg.install {
        inherit application variants;
      })
    cfg.applications;

    resolved = lib.attrsets.mapAttrs (application: selection:
      selection
      // {
        inherit application;
      })
    (lib.attrsets.filterAttrs (_: selection: selection != null) selections);
  in {
    options.appStore = {
      applications = lib.options.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf variantType);
        default = {};
        description = "Logical applications keyed by installation tool, with tool-private variant values.";
      };

      tools = lib.options.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.enable = lib.options.mkEnableOption "application-store installation tool";
        });
        default = {};
        description = "Installation tools available to user selection policy.";
      };

      install = lib.options.mkOption {
        type = lib.types.functionTo (lib.types.nullOr lib.types.attrs);
        description = "User policy callback selecting and invoking a tool hook for a logical application.";
      };

      resolved = lib.options.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        internal = true;
        readOnly = true;
      };
    };

    config.appStore.resolved = resolved;
  };
}

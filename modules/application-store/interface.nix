{lib, ...}: {
  flake.modules.darwin.app-store = {config, ...}: let
    cfg = config.appStore;

    resolved = lib.attrsets.mapAttrs (application: tool:
      cfg.applications.${application}.${tool}
      // {
        inherit application tool;
      })
    cfg.installations;
  in {
    options.appStore = {
      applications = lib.options.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.attrs);
        default = {};
        description = "Logical applications keyed by installation tool, with tool-private variant values.";
      };

      installations = lib.options.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Selected installation tool keyed by logical application.";
      };

      resolved = lib.options.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        internal = true;
        readOnly = true;
      };
    };

    config.appStore = {
      inherit resolved;
    };
  };
}

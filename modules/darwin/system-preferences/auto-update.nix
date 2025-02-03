{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.system-preferences.auto-update;
in {
  options = {
    krad246.darwin.system-preferences.auto-update =
      lib.options.mkEnableOption "auto-update"
      // {
        default = true;
      };
  };

  config = lib.modules.mkIf cfg {
    system.defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    };
  };
}

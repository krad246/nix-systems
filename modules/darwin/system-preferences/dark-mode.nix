{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.system-preferences.dark-mode;
in {
  options = {
    krad246.darwin.system-preferences.dark-mode =
      lib.options.mkEnableOption "dark-mode"
      // {
        default = true;
      };
  };

  config = lib.modules.mkIf cfg {
    system.defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
      };
    };
  };
}

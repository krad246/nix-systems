{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.launchcontrol;
in {
  options = {
    krad246.darwin.apps.launchcontrol =
      lib.options.mkEnableOption "launchcontrol"
      // {
        default = true;
      };
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["launchcontrol"];
    };
  };
}

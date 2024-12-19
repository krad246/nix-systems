{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.bluesnooze;
in {
  options = {
    krad246.darwin.apps.bluesnooze = lib.options.mkEnableOption "bluesnooze";
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["bluesnooze"];
    };
  };
}

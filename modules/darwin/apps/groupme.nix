{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.groupme;
in {
  options = {
    krad246.darwin.apps.groupme = lib.options.mkEnableOption "groupme" // {default = true;};
  };

  config = {
    homebrew = {
      masApps = lib.modules.mkIf cfg {
        "Unite - GroupMe app" = 1152517150;
      };
    };
  };
}

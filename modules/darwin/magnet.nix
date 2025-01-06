{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.magnet;
in {
  options = {
    krad246.darwin.apps.magnet = lib.options.mkEnableOption "magnet" // {default = true;};
  };

  config = {
    homebrew = {
      masApps = {
        "Magnet" = lib.modules.mkIf cfg 441258766;
      };
    };
  };
}

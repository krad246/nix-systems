{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.signal;
in {
  options = {
    krad246.darwin.apps.signal =
      lib.options.mkEnableOption "signal"
      // {
        default = true;
      };
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["signal"];
    };
  };
}

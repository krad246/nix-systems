{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.utm;
in {
  options = {
    krad246.darwin.apps.utm =
      lib.options.mkEnableOption "utm"
      // {
        default = true;
      };
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["crystalfetch" "utm"];
    };
  };
}

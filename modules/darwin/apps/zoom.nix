{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.zoom;
in {
  options = {
    krad246.darwin.apps.zoom =
      lib.options.mkEnableOption "zoom"
      // {
        default = true;
      };
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["zoom"];
    };
  };
}

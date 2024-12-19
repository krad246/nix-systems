{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.spotify;
in {
  options = {
    krad246.darwin.apps.spotify = lib.options.mkEnableOption "spotify";
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["spotify"];
    };
  };
}

{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.windows-app;
in {
  options = {
    krad246.darwin.apps.windows-app = lib.options.mkEnableOption "windows-app";
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["windows-app"];
    };
  };
}

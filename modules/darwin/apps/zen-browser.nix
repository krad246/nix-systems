{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.zen-browser;
in {
  options = {
    krad246.darwin.apps.zen-browser = lib.options.mkEnableOption "zen-browser" // {default = true;};
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["zen"];
    };
  };
}

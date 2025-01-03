{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.kitty;
in {
  options = {
    krad246.darwin.apps.kitty =
      lib.options.mkEnableOption "kitty"
      // {
        default = true;
      };
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["kitty"];
    };
  };
}

{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.arc;
in {
  options = {
    krad246.darwin.apps.arc = lib.options.mkEnableOption "arc";
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["arc"];
    };
  };
}

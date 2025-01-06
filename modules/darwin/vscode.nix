{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.vscode;
in {
  options = {
    krad246.darwin.apps.vscode =
      lib.options.mkEnableOption "vscode"
      // {
        default = true;
      };
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["visual-studio-code"];
    };
  };
}

{lib, ...}: {
  flake.modules.homeManager.bat = {config, ...}: let
    cfg = config.shell.programs.bat;
  in {
    options.shell.programs.bat.integrations.delta.enable =
      lib.options.mkEnableOption "Whether to enable `delta` integration for `bat`.";

    config = lib.modules.mkIf cfg.integrations.delta.enable {
      nixpkgs.overlays = [
        (_: prev: {
          bat-extras = prev.bat-extras.overrideScope (_: bat-extras: {
            batdiff = bat-extras.batdiff.override {
              withDelta = true;
            };
          });
        })
      ];

      home.sessionVariables.BATDIFF_USE_DELTA = "true";
    };
  };
}

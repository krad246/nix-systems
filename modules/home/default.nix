{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.specialisation.default.configuration;
in {
  imports = with self.homeModules;
    [shellenv]
    ++ (with self.modules.generic; [
      home-link-registry
      flake-registry
    ]);

  specialisation = {
    default = lib.modules.mkDefault {
      configuration = _: {};
    };
  };

  home.activation = lib.modules.mkIf (config.specialisation != {}) {
    switchToSpecialisation = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${lib.meta.getExe cfg.home.activationPackage}
    '';
  };

  home.stateVersion = lib.trivial.release;

  manual = {
    html.enable = true;
    json.enable = true;
  };
}

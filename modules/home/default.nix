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

  home = {
    file.dotfiles.source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles";

    activation = lib.modules.mkIf (config.specialisation != {}) {
      switchToSpecialisation = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${lib.meta.getExe cfg.home.activationPackage}
      '';
    };

    stateVersion = lib.trivial.release;
  };

  manual = {
    html.enable = true;
    json.enable = true;
  };

  xdg.configFile = {
    dotfiles = {
      enable = false;
      source = self;
    };
  };
}

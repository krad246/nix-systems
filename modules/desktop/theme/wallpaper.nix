{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.theme.wallpaper = {
      light = lib.options.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Light-mode wallpaper URI.";
      };

      dark = lib.options.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Dark-mode wallpaper URI.";
      };

      primaryColor = lib.options.mkOption {
        type = lib.types.str;
        default = "#241f31";
        description = "Fallback primary wallpaper color.";
      };

      secondaryColor = lib.options.mkOption {
        type = lib.types.str;
        default = "#000000";
        description = "Fallback secondary wallpaper color.";
      };
    };
  };
}

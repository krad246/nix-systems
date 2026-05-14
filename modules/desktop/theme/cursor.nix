{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.theme.cursor = {
      name = lib.options.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "WhiteSure-cursors";
        description = "Cursor theme name for desktop environments that expose one.";
      };
    };
  };
}

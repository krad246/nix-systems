{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.theme.icons = {
      name = lib.options.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "WhiteSure-dark";
        description = "Icon theme name for desktop environments that expose one.";
      };
    };
  };
}

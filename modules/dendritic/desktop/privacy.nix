{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.privacy = {
      oldFilesAge = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 30;
        description = "Age in days for old files in desktop privacy settings.";
      };

      recentFilesMaxAge = lib.options.mkOption {
        type = lib.types.int;
        default = -1;
        description = "Maximum age in days for recent files.";
      };
    };
  };
}

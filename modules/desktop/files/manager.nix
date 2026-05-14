{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.files.manager = {
      showHidden = lib.options.mkEnableOption "hidden files" // {default = true;};
      showExtensions = lib.options.mkEnableOption "file extensions" // {default = true;};
      showPathBar = lib.options.mkEnableOption "file-manager path bar" // {default = true;};
      showStatusBar = lib.options.mkEnableOption "file-manager status bar" // {default = true;};
      createDesktop = lib.options.mkEnableOption "desktop icons in the file manager" // {default = true;};
      removeOldTrashItems = lib.options.mkEnableOption "automatic old-trash cleanup" // {default = true;};
      sortFoldersFirst = lib.options.mkEnableOption "sorting folders first" // {default = true;};
    };
  };
}

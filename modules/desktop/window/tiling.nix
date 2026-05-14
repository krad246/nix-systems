{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.window = {
      edgeTiling = lib.options.mkEnableOption "edge tiling" // {default = true;};
      currentWorkspaceSwitcher = lib.options.mkEnableOption "current-workspace-only app switching" // {default = true;};
    };
  };
}

{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.workspaces = {
      dynamic = lib.options.mkEnableOption "dynamic workspaces" // {default = true;};
      spanDisplays = lib.options.mkEnableOption "workspaces spanning displays";
      switchToAppSpace = lib.options.mkEnableOption "switching to a Space with open windows for an activated app" // {default = true;};
      mostRecentFirst = lib.options.mkEnableOption "automatically rearranging Spaces by recent use" // {default = true;};
    };
  };
}

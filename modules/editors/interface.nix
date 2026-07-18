{lib, ...}: {
  flake.modules.homeManager.editor = {
    options.editor.backends.helix = {
      enable = lib.options.mkEnableOption "Helix editor backend";
      default = lib.options.mkEnableOption "Helix as the default editor";
    };
  };
}

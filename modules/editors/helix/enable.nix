{
  flake.modules.homeManager.helix = {
    config,
    lib,
    ...
  }: {
    options.editor.backends.helix = {
      enable = lib.options.mkEnableOption "Helix editor backend";
      default = lib.options.mkEnableOption "Helix as the default editor";
    };

    config.programs.helix = {
      enable = lib.modules.mkDefault config.editor.backends.helix.enable;
      defaultEditor = lib.modules.mkDefault config.editor.backends.helix.default;
    };
  };
}

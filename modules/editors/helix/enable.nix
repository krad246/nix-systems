{
  flake.modules.homeManager.helix = {
    config,
    lib,
    ...
  }: {
    programs.helix = {
      enable = lib.modules.mkDefault config.editor.backends.helix.enable;
      defaultEditor = lib.modules.mkDefault config.editor.backends.helix.default;
    };
  };
}

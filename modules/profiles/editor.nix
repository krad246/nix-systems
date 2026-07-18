{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.editor = {
    imports = [self.modules.homeManager.helix];

    editor.backends.helix = {
      enable = lib.modules.mkDefault true;
      default = lib.modules.mkDefault true;
    };
  };
}

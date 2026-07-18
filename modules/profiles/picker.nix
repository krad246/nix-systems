{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.picker = {
    imports = [self.modules.homeManager.fzf];

    picker.backends.fzf.enable = lib.modules.mkDefault true;
  };
}

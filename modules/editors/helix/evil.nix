{
  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix = {
      package = pkgs.evil-helix;
      settings.editor.evil = true;
    };
  };
}

{
  flake.modules.homeManager.kitty = {pkgs, ...}: {
    programs.kitty = {
      themeFile = "GruvboxMaterialDarkSoft";
      font = {
        name = "meslo-lg";
        size = 20.0;
        package = pkgs.nerd-fonts.meslo-lg;
      };
    };
  };
}

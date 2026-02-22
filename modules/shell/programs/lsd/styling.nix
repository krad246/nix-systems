{
  flake.modules.homeManager.lsd = {lib, ...}: {
    programs.lsd = {
      colors = lib.strings.fromJSON (builtins.readFile ./colors.json);
      icons = {};
    };
  };
}

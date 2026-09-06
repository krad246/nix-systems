{lib, ...}: {
  flake.modules.homeManager.lsd = {
    programs.lsd = {
      colors = lib.strings.fromJSON (builtins.readFile ./colors.json);
      icons = {};
    };
  };
}

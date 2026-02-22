{
  flake.modules.homeManager.starship = {lib, ...}: {
    programs.starship.settings = lib.trivial.importTOML ./starship.toml;
  };
}

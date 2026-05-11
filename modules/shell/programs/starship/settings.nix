{lib, ...}: {
  flake.modules.homeManager.starship = {
    programs.starship.settings = lib.trivial.importTOML ./starship.toml;
  };
}

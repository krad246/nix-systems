{lib, ...}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = lib.trivial.importTOML ./starship.toml;
  };
}

{
  config,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    settings = lib.trivial.importTOML ./starship.toml;
  };
}

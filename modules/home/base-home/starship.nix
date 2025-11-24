{
  config,
  lib,
  ...
}: let
  # inherit (pkgs) lib;
  inherit (lib) trivial;
in {
  programs.starship = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    settings = trivial.importTOML ./starship.toml;
  };
}

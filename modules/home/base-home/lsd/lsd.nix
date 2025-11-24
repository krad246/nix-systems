{
  config,
  lib,
  ...
}: let
  # inherit (pkgs) lib;
  inherit (lib) strings;
in {
  programs.lsd = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;

    colors = strings.fromJSON (builtins.readFile ./colors.json);
    icons = {};
    settings = {
      hyperlink = "auto";
    };
  };

  programs.bash.shellAliases = let
    inherit (lib) meta;
  in {
    l = meta.getExe config.programs.lsd.package;
  };
}

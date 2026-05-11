{
  flake.modules.nixos.theme = {pkgs, ...}: {
    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-soft.yaml";
      polarity = "dark";
    };
  };
}

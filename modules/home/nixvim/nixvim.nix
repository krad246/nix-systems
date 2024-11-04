{
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) system;
in {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    package = inputs.nixvim-config.packages.${system}.default;
  };
}

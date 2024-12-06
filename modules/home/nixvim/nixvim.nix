{
  inputs,
  pkgs,
  lib,
  ezModules,
  ...
}: let
  inherit (pkgs.stdenv) system;
  nixvim = inputs.nixvim-config.packages.${system}.default;

  inherit (lib) meta;
in {
  imports = [ezModules.nerdfonts];
  home = {
    packages = [nixvim] ++ (with pkgs; [nil nixd nixpkgs-fmt]);

    shellAliases = {
      vi = meta.getExe nixvim;
      vim = meta.getExe nixvim;
      vimdiff = "${meta.getExe nixvim} -d";
    };
    sessionVariables = {
      EDITOR = meta.getExe nixvim;
    };
  };
}

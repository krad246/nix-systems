{
  inputs,
  pkgs,
  lib,
  ezModules,
  ...
}: let
  inherit (pkgs.stdenv) system;
  nixvim = inputs.nixvim-config.packages.${system}.default;
in {
  imports = [ezModules.nerdfonts];
  home = {
    packages = [nixvim] ++ (with pkgs; [nil nixd nixpkgs-fmt]);

    shellAliases = {
      vi = lib.getExe nixvim;
      vim = lib.getExe nixvim;
      vimdiff = "${lib.getExe nixvim} -d";
    };
    sessionVariables = {
      EDITOR = lib.getExe nixvim;
    };
  };
}

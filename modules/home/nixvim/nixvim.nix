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
      vi = lib.meta.getExe nixvim;
      vim = lib.meta.getExe nixvim;
      vimdiff = "${lib.meta.getExe nixvim} -d";
    };
    sessionVariables = {
      EDITOR = lib.meta.getExe nixvim;
    };
  };
}

{
  withSystem,
  self,
  lib,
  pkgs,
  ...
}: let
  nixvim = withSystem pkgs.stdenv.system ({inputs', ...}: inputs'.nixvim-config.packages.default);
  inherit (lib) meta;
in {
  imports = [self.homeModules.nerdfonts];

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

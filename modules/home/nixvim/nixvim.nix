{
  withSystem,
  self,
  lib,
  pkgs,
  ...
}: let
  nixvim = withSystem pkgs.stdenv.system ({inputs', ...}: inputs'.nixvim-config.packages.default);
in {
  imports = [self.homeModules.nerdfonts];

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

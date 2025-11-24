{
  config,
  lib,
  pkgs,
  ...
}: let
  # inherit (pkgs) lib;
  inherit (lib) meta trivial;

  batdiff = pkgs.bat-extras.batdiff.override {withDelta = true;};
  batwatch = pkgs.bat-extras.batwatch.override {withEntr = true;};
in {
  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
      batpipe
      batwatch
      prettybat
    ];
  };

  programs.bash = {
    shellAliases = {
      cat = "${meta.getExe config.programs.bat.package} -pp";
      brg = meta.getExe pkgs.bat-extras.batgrep;
      man = meta.getExe pkgs.bat-extras.batman;
      bdiff = meta.getExe batdiff;
    };

    sessionVariables = {
      BATDIFF_USE_DELTA = trivial.boolToString true;
      LESSOPEN = "|${meta.getExe pkgs.bat-extras.batpipe} %s";
      LESS = "$LESS -R";
      BATPIPE = "color";
    };
  };

  # home.packages = with pkgs; [
  #   entr
  #   delta
  # ];
}

{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) meta;
in {
  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
    extraPackages = with pkgs.bat-extras; [
      batgrep
      batman
      batwatch
      batdiff
      batpipe
    ];
  };

  home = {
    shellAliases = rec {
      cat = meta.getExe config.programs.bat.package;
      brg = meta.getExe pkgs.bat-extras.batgrep;
      man = meta.getExe pkgs.bat-extras.batman;

      watch = meta.getExe (pkgs.bat-extras.batwatch.override {
        withEntr = true;
      });

      tail = watch;
      diff = meta.getExe (pkgs.bat-extras.batdiff.override {
        withDelta = true;
      });
    };

    sessionVariables = {
      BATDIFF_USE_DELTA = lib.trivial.boolToString true;
      LESSOPEN = "|${meta.getExe pkgs.bat-extras.batpipe} %s";
      LESS = "$LESS -R";
      BATPIPE = "color";
    };
  };

  home.packages = with pkgs; [
    entr
    delta
  ];
}

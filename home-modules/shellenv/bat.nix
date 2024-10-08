{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
    extraPackages = with pkgs.bat-extras; [batgrep batman batwatch batdiff batpipe];
  };

  home = {
    shellAliases = rec {
      cat = lib.getExe config.programs.bat.package;
      bag = lib.getExe pkgs.bat-extras.batgrep;
      man = lib.getExe pkgs.bat-extras.batman;
      watch = lib.getExe (pkgs.bat-extras.batwatch.override {withEntr = true;});
      tail = watch;
      diff = lib.getExe (pkgs.bat-extras.batdiff.override {withDelta = true;});
    };

    sessionVariables = {
      BATDIFF_USE_DELTA = lib.trivial.boolToString true;
      LESSOPEN = "|${lib.getExe pkgs.bat-extras.batpipe} %s";
      LESS = "$LESS -R";
      BATPIPE = "color";
    };
  };

  home.packages = with pkgs; [
    entr
    delta
  ];
}

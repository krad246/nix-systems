{
  lib,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = true;
  home.packages = lib.mkIf pkgs.stdenv.isDarwin (with pkgs; [
    (nerdfonts.override {
      fonts = ["Meslo" "NerdFontsSymbolsOnly"];
    })
  ]);
}

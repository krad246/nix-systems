{pkgs, ...}:
pkgs.nerdfonts.override {
  fonts = ["CascadiaCode" "Meslo" "NerdFontsSymbolsOnly"];
}

{pkgs, ...}:
pkgs.symlinkJoin {
  name = "term-fonts";
  paths = [
    pkgs.cascadia-code
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.symbols-only
  ];
}

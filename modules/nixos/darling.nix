{pkgs, ...}: {
  programs.darling.enable = pkgs.stdenv.isx86_64;
}

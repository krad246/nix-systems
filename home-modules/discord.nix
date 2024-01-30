{pkgs, ...}: let
  discord =
    if pkgs.stdenv.isDarwin
    then pkgs.discord
    else
      (
        if pkgs.stdenv.isLinux
        then pkgs.vesktop
        else throw "Unsupported platform!"
      );
in {
  home.packages = [discord];
}

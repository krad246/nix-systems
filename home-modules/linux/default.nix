args @ {
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  (import ./chromium.nix args)
  (import ./kdeconnect.nix args)
  (import ./webcord.nix (args // {inherit pkgs;}))
  (import ./xdg.nix (args // {inherit pkgs;}))
  {home.packages = with pkgs; [pavucontrol];}
]

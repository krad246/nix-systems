{
  withSystem,
  pkgs,
  ...
}: {
  programs.rbw = {
    enable = true;
    package = withSystem pkgs.stdenv.system ({inputs', ...}: inputs'.nixos-unstable.legacyPackages.rbw);
    settings = {
      email = "krad246@gmail.com";
      pinentry =
        if pkgs.stdenv.isDarwin
        then pkgs.pinentry_mac
        else pkgs.pinentry;
    };
  };
}

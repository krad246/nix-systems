{pkgs, ...}: {
  programs.rbw = {
    enable = true;
    package = pkgs.rbw;
    settings = {
      email = "krad246@gmail.com";
      pinentry =
        if pkgs.stdenv.isDarwin
        then pkgs.pinentry_mac
        else pkgs.pinentry;
    };
  };
}

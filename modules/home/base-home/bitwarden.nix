{pkgs, ...}: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "krad246@gmail.com";
      pinentry =
        if pkgs.stdenv.isDarwin
        then pkgs.pinentry_mac
        else pkgs.pinentry;
    };
  };
}

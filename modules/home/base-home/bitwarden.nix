{
  withSystem,
  pkgs,
  ...
}: {
  programs.rbw = {
    enable = true;
    package = withSystem pkgs.stdenv.system (ctx: ctx.pkgs.rbw);
    settings = {
      email = "krad246@gmail.com";
      pinentry =
        if pkgs.stdenv.isDarwin
        then pkgs.pinentry_mac
        else pkgs.pinentry;
    };
  };
}

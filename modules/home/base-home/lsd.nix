{
  config,
  lib,
  ...
}: {
  programs.lsd = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash.shellAliases = let
    inherit (lib) meta;
  in {
    l = meta.getExe config.programs.lsd.package;
    # ls = l;
    # ll = "${ls} -gl";
    # la = "${ll} -A";
    # lal = la;
  };
}

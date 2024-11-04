{
  self,
  config,
  ...
}: {
  imports = [self.modules.generic.ccache-stdenv];

  systemd.tmpfiles.rules = [
    "d ${config.programs.ccache.cacheDir}                        770 root    nixbld  - -"
  ];
}

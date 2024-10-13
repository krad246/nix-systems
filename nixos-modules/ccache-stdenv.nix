{config, ...}: {
  imports = [../common/ccache-stdenv.nix];

  systemd.tmpfiles.rules = [
    "d ${config.programs.ccache.cacheDir}                        770 root    nixbld  - -"
  ];
}

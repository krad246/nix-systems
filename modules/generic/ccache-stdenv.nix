{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.ccache.enable = true;

  nixpkgs.overlays = [
    (_self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = let
          echo = lib.meta.getExe' pkgs.coreutils "echo";
          sudo = lib.meta.getExe pkgs.sudo;
        in ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          if [ ! -d "$CCACHE_DIR" ]; then
            ${echo} "====="
            ${echo} "Directory '$CCACHE_DIR' does not exist"
            ${echo} "Please create it with:"
            ${echo} "  ${sudo} ${lib.meta.getExe' pkgs.coreutils "mkdir"} -m0770 '$CCACHE_DIR'"
            ${echo} "  ${sudo} ${lib.meta.getExe' pkgs.coreutils "chown"} root:nixbld '$CCACHE_DIR'"
            ${echo} "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            ${echo} "====="
            ${echo} "Directory '$CCACHE_DIR' is not accessible for user $(${lib.meta.getExe' pkgs.coreutils "whoami"})"
            ${echo} "Please verify its access permissions"
            ${echo} "====="
            exit 1
          fi
        '';
      };
    })
  ];

  nix.settings.extra-sandbox-paths = [config.programs.ccache.cacheDir];
}

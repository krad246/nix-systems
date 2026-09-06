{
  flake.modules.nixos.ccache = {config, ...}: {
    programs.ccache = {
      enable = true;
      packageNames = [
      ];
    };

    nix.settings.extra-sandbox-paths = [config.programs.ccache.cacheDir];
  };
}

{
  perSystem = {config, ...}: {
    formatter = config.treefmt.build.wrapper;
    treefmt = {
      inherit (config.flake-root) projectRootFile;
      programs = {
        deadnix.enable = true;
        alejandra.enable = true;
        statix.enable = true;
      };
    };

    pre-commit.settings.hooks = {
      nil.enable = true;
      deadnix.enable = true;
      alejandra.enable = true;
      statix.enable = true;
    };
  };
}

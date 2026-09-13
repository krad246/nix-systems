{lib, ...}: {
  options = {
    buildPlatforms = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf (lib.types.submodule {
        options.system = lib.mkOption {
          type = lib.types.str;
          description = "A platform constraint identified by its system string.";
        };
      }));
      default = null;
      description = "Optional constraints describing valid build platforms; null permits every declared flake system.";
    };
    crossCompile = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether differing build and host platforms are permitted.";
    };
  };
}

{
  lib,
  platformType,
  ...
}: {
  options = {
    buildPlatforms = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf platformType);
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

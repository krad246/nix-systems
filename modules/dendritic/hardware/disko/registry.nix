{lib, ...}: {
  options.flake.diskoConfigurations = lib.options.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    default = {};
    description = "Named disko module presets available to system declarations.";
  };
}

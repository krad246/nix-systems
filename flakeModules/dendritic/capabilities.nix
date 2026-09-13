{lib, ...}: {
  options.dendritic.internal.capabilityTags = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    readOnly = true;
    internal = true;
    default = ["virtualisation"];
    description = "Framework-recognized capability tags that do not select profile aspects.";
  };
}

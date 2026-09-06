{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.input.pointer = {
      naturalScrolling = lib.options.mkEnableOption "natural pointer scrolling";

      accelerationProfile = lib.options.mkOption {
        type = lib.types.enum ["default" "flat" "adaptive"];
        default = "flat";
        description = "Pointer acceleration profile requested from desktop backends.";
      };
    };
  };
}

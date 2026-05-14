{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.preferences = {
      automaticTermination = lib.options.mkEnableOption "automatic app termination";
      springLoading = lib.options.mkEnableOption "spring-loaded folders and directories" // {default = true;};

      alertVolume = lib.options.mkOption {
        type = lib.types.float;
        default = 0.5;
        description = "Desktop alert volume where supported.";
      };
    };
  };
}

{lib, ...}: {
  options = {
    krad246.darwin.virtualisation.docker-desktop = lib.options.mkEnableOption "docker-desktop";
  };

  config = {
    homebrew = {
      casks = ["docker"];
    };
  };
}

{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.dock.apps.pinned = lib.options.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "phone-mirroring"
        "launchpad"
        "file-manager"
        "browser"
        "terminal"
        "editor"
      ];
      description = "Logical application IDs pinned by desktop dock implementations.";
    };
  };
}

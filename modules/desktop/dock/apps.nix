{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.dock.apps.pinned = lib.options.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "browser"
        "phone-mirroring"
        "launchpad"
        "file-manager"
        "terminal"
        "editor"
      ];
      description = "Logical application IDs pinned by desktop dock implementations.";
    };
  };
}

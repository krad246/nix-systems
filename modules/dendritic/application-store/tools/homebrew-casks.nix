{lib, ...}: {
  flake.modules.darwin.app-store-tool-homebrew-casks = {config, ...}: let
    applications = lib.attrsets.filterAttrs (_: application: application.tool == "homebrew.casks") config.appStore.resolved;
  in {
    config = lib.modules.mkIf config.appStore.tools."homebrew.casks".enable {
      appManagement.backends.homebrew.enable = true;
      homebrew.casks = lib.lists.concatLists (lib.attrsets.mapAttrsToList (_: application: application.value.install) applications);
    };
  };
}

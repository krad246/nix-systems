{lib, ...}: {
  flake.modules.darwin.app-store-tool-mas-apps = {
    config,
    pkgs,
    ...
  }: let
    applications = lib.attrsets.filterAttrs (_: application: application.tool == "mas.apps") config.appStore.resolved;
  in {
    config = lib.modules.mkIf config.appStore.tools."mas.apps".enable {
      appManagement.backends.homebrew.enable = true;
      environment.systemPackages = [pkgs.mas];
      homebrew.masApps = lib.attrsets.mergeAttrsList (lib.attrsets.mapAttrsToList (_: application: application.value.install) applications);
    };
  };
}

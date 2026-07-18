{lib, ...}: {
  flake.modules.darwin.app-store-homebrew-cask = {config, ...}: let
    applications = lib.attrsets.filterAttrs (_: application: application.tool == "homebrew-cask") config.appStore.resolved;
  in {
    options.appStore.backends.homebrew-cask.enable =
      lib.options.mkEnableOption "Homebrew cask application-store backend";

    config = lib.modules.mkIf config.appStore.backends.homebrew-cask.enable {
      appManagement.backends.homebrew.enable = true;
      homebrew.casks = lib.attrsets.mapAttrsToList (_: application: application.identifier) applications;
    };
  };
}

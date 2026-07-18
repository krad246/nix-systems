{lib, ...}: {
  flake.modules.darwin.app-store-mas = {
    config,
    pkgs,
    ...
  }: let
    applications = lib.attrsets.filterAttrs (_: application: application.tool == "mas") config.appStore.resolved;
  in {
    options.appStore.backends.mas.enable =
      lib.options.mkEnableOption "Mac App Store backend using mas";

    config = lib.modules.mkIf config.appStore.backends.mas.enable {
      appManagement.backends.homebrew.enable = true;
      environment.systemPackages = [pkgs.mas];
      homebrew.masApps = lib.attrsets.mapAttrs' (_: application:
        lib.attrsets.nameValuePair application.displayName (builtins.fromJSON application.identifier))
      applications;
    };
  };
}

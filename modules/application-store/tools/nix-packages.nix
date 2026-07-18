{lib, ...}: {
  flake.modules.darwin.app-store-tool-nix-packages = {config, ...}: let
    applications = lib.attrsets.filterAttrs (_: application: application.tool == "nix.packages") config.appStore.resolved;
  in {
    config = lib.modules.mkIf config.appStore.tools."nix.packages".enable {
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = lib.lists.concatLists (lib.attrsets.mapAttrsToList (_: application: application.value.install) applications);
    };
  };
}

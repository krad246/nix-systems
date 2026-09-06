{
  flake.modules.darwin.discord = {pkgs, ...}: {
    appStore.applications.discord."nix.packages".install = [pkgs.discord];
  };
}

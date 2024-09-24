{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) nixpkgs-unstable;
  unstable = import nixpkgs-unstable {
    inherit (pkgs.stdenv) system;
    config.allowUnfree = true;
  };
in {
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    package = unstable.steam;

    extest.enable = true;
    # protontricks.enable = true;

    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

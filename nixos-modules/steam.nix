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
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}

{
  osConfig,
  inputs,
  ezModules,
  lib,
  ...
}: let
  # found in the minimal profile
  noXlibs = lib.attrsets.attrByPath ["environment" "noXlibs"] false osConfig;
  hasXEnabled =
    if noXlibs
    then false
    else osConfig.services.xserver.enable; # usually true.

  # nixos-generators vm-nogui sets this to false
  isGraphicalVM = lib.attrsets.attrByPath ["virtualisation" "graphics" "enable"] false osConfig;

  # WSL instances define this attribute
  isWSL = lib.attrsets.attrByPath ["wsl" "enable"] false osConfig;

  # docker images set this
  isContainer = lib.attrsets.attrByPath ["boot" "isContainer"] false osConfig;
  isGraphicalNixOS =
    if (isWSL || isContainer || (!hasXEnabled) || (!isGraphicalVM))
    then false
    else hasXEnabled;
  inherit (inputs) nix-flatpak;
in {
  imports =
    [nix-flatpak.homeManagerModules.nix-flatpak]
    ++ (
      lib.optionals isGraphicalNixOS (with ezModules; [
        chromium
        discord
        dconf
        kdeconnect
        kitty
        vscode
        vscode-server
      ])
    );

  services = lib.mkIf isGraphicalNixOS {
    flatpak.packages = [
      "org.pulseaudio.pavucontrol"
      "us.zoom.Zoom"
      "org.signal.Signal"
      "com.spotify.Client"
      "com.valvesoftware.Steam"
      "com.github.tchx84.Flatseal"
    ];
  };
}

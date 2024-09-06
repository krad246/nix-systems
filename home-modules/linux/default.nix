{
  osConfig,
  inputs,
  ezModules,
  lib,
  ...
}: let
  inherit (inputs) nix-flatpak;

  # found in the minimal profile
  noXlibs = lib.attrsets.attrByPath ["environment" "noXlibs"] false osConfig;
  hasXEnabled =
    if noXlibs
    then false
    else lib.attrsets.attrByPath ["services" "xserver" "enable"] false osConfig; # usually true.
  hasFlatpak = lib.attrsets.attrByPath ["services" "flatpak" "enable"] false osConfig;

  # WSL instances define this attribute
  isWSL = lib.attrsets.attrByPath ["wsl" "enable"] false osConfig;

  # docker images set this
  isContainer = lib.attrsets.attrByPath ["boot" "isContainer"] false osConfig;

  # common for VMs
  growableRoot = lib.attrsets.attrByPath ["boot" "growPartition"] false osConfig;

  isVM =
    isContainer
    || growableRoot
    || (lib.attrsets.hasAttrByPath ["virtualisation" "diskSize"]
      osConfig);
  isGraphicalNixOS = let
    vmGui =
      lib.attrsets.attrByPath ["virtualisation" "graphics"]
      true
      osConfig;
  in
    if (isWSL || isContainer || (!hasXEnabled) || !vmGui)
    then false
    else hasXEnabled;

  baseModules = lib.debug.traceIf isGraphicalNixOS "base modules" isGraphicalNixOS;
  extendedModules = let
    rest = baseModules && !isVM;
  in
    lib.debug.traceIf rest "extended modules"
    rest;
in {
  imports =
    [nix-flatpak.homeManagerModules.nix-flatpak]
    ++ [
      ezModules.nerdfonts
    ]
    ++ (lib.optionals baseModules [ezModules.chromium ezModules.dconf ezModules.kitty])
    ++ (lib.optionals extendedModules (with ezModules; [
      discord
      kdeconnect
      vscode
      vscode-server
    ]));

  services = lib.mkIf (extendedModules && hasFlatpak) {
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

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

  # WSL instances define this attribute
  isWSL = lib.attrsets.attrByPath ["wsl" "enable"] false osConfig;

  # docker images set this
  isContainer = lib.attrsets.attrByPath ["boot" "isContainer"] false osConfig;

  # common for VMs
  growableRoot = lib.attrsets.attrByPath ["boot" "growPartition"] false osConfig;

  isIso = lib.attrsets.hasAttrByPath ["system" "build" "isoImage"] osConfig;

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

  baseModules = isGraphicalNixOS;
  extendedModules = let
    rest = baseModules && !isVM && !isIso;
  in
    rest;
  flatpakModules = true;
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

  services = lib.mkIf flatpakModules {
    flatpak = {
      uninstallUnmanaged = true;
      update.onActivation = true;
      packages =
        [
          "org.pulseaudio.pavucontrol"
          "us.zoom.Zoom"
          "org.signal.Signal"
          "com.spotify.Client"
          "com.github.tchx84.Flatseal"
        ]
        ++ (lib.optionals (!(lib.attrsets.attrByPath ["programs" "steam" "enable"] false osConfig)) [
          "com.valvesoftware.Steam"
        ]);
    };
  };

  xdg.desktopEntries = lib.mkIf baseModules {
    "org.kde.kdeconnect.nonplasma" = {
      name = "org.kde.kdeconnect.nonplasma";
      noDisplay = true;
    };
    "org.gnome.Software" = {
      name = "org.gnome.Software";
      noDisplay = true;
    };
    "bottom" = {
      name = "bottom";
      noDisplay = true;
    };
  };
}

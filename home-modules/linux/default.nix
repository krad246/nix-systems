{
  osConfig,
  inputs,
  ezModules,
  lib,
  ...
}: let
  wsl = lib.attrsets.attrByPath ["wsl"] {enable = false;} osConfig;
  xserver = lib.attrsets.attrByPath ["services" "xserver"] {enable = false;} osConfig;

  isGraphicalNixOS = !wsl.enable && xserver.enable;
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

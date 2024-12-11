{
  inputs,
  self,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs) nix-flatpak;
  inherit (lib) modules lists;
in {
  imports = [nix-flatpak.homeManagerModules.nix-flatpak];

  services.flatpak.uninstallUnmanaged = modules.mkDefault false;
  targets.genericLinux.enable = true;

  specialisation = rec {
    default = modules.mkDefault generic-linux;

    generic-linux = {
      configuration = _: {
        imports = with self.homeModules;
          [
            chromium
            dconf
            kitty
          ]
          ++ lists.optionals pkgs.stdenv.isx86_64 [zen-browser];

        services = {
          flatpak = {
            uninstallUnmanaged = false;
            update = {
              auto.enable = true;
              onActivation = true;
            };
            packages = [
              "org.pulseaudio.pavucontrol"
              "com.github.tchx84.Flatseal"
            ];
          };
        };

        xdg.desktopEntries = {
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
      };
    };
  };
}

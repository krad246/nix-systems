{
  inputs,
  self,
  lib,
  ...
}: let
  inherit (inputs) nix-flatpak;
  inherit (lib) modules;

  generic-linux = {
    configuration = _: {
      imports = with self.homeModules; [
        chromium
        dconf
        kitty
      ];

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
in {
  imports = [nix-flatpak.homeManagerModules.nix-flatpak] ++ [generic-linux.configuration];

  services.flatpak.uninstallUnmanaged = modules.mkDefault false;
  targets.genericLinux.enable = true;

  specialisation = rec {
    default = modules.mkDefault generic-linux;

    inherit generic-linux;
  };
}

args @ {
  inputs,
  self,
  lib,
  ...
}: let
  inherit (inputs) nix-flatpak;
  inherit (lib) modules;
in {
  imports = [nix-flatpak.homeManagerModules.nix-flatpak];

  targets.genericLinux.enable = true;

  specialisation = rec {
    default = modules.mkDefault generic-linux;

    generic-linux = {
      configuration = _: {
        imports = with self.homeModules; [
          dconf # conditionally enabled if the system dconf is enabled
          kitty
        ];

        dconf.enable = lib.attrsets.attrByPath ["osConfig" "programs" "dconf" "enable"] false args;

        services = {
          flatpak = {
            uninstallUnmanaged = false;
            update = {
              auto.enable = true;
              onActivation = true;
            };
            packages = [
              "app.zen_browser.zen"
              "org.pulseaudio.pavucontrol"
              "com.github.tchx84.Flatseal"
            ];
          };
        };

        xdg = {
          enable = true;
          desktopEntries = {
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
  };
}

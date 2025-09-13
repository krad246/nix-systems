args @ {
  inputs,
  self,
  lib,
  ...
}: let
  inherit (inputs) nix-flatpak;
in {
  imports = [nix-flatpak.homeManagerModules.nix-flatpak];

  targets.genericLinux.enable = true;
  systemd.user.startServices = "sd-switch";

  # add a default set of linux apps into an activatable specialization
  # this overwrites the default specialization
  specialisation = rec {
    default = generic-linux;

    generic-linux = {
      configuration = {
        imports =
          [./dconf.nix]
          ++ (with self.homeModules; [
            kitty
            vscode
            vscode-server
          ]);

        # Don't mutate dconf settings unless we can guarantee that dconf is running in the surrounding system.
        # For simplicity's sake this means that NixOS Gnome setups will enable this but in no other case will
        # these settings activate.
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
          };
        };
      };
    };
  };
}

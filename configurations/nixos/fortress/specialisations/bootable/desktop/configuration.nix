{
  self,
  lib,
  pkgs,
  ...
}: {
  imports =
    [self.modules.generic.unfree]
    ++ (with self.nixosModules; [
      ])
    ++ [
      ./bluetooth.nix
      ./flatpak.nix
      ./kdeconnect-ports.nix
      ./opengl.nix
      ./pipewire.nix
      ./system76-scheduler.nix
    ];

  home-manager.sharedModules = let
    fortress = {
      configuration = {...}: {
        imports = with self.homeModules; [
          discord
          kdeconnect
          vscode
          vscode-server
        ];

        services = {
          flatpak = {
            packages = [
              "us.zoom.Zoom"
              "org.signal.Signal"
              "com.valvesoftware.Steam"
            ];
          };
        };
      };
    };
  in [
    ({lib, ...}: {
      imports = [
        fortress.configuration
      ];
      specialisation = rec {
        default = lib.modules.mkForce fortress;
        inherit fortress;
      };
    })
  ];

  services = {
    gnome.gnome-remote-desktop.enable = true;
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = lib.meta.getExe pkgs.gnome.gnome-session;
  services.xrdp.openFirewall = true;
}

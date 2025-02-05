{
  self,
  lib,
  pkgs,
  ...
}: {
  imports =
    [self.modules.generic.unfree]
    ++ [
      ./bluetooth.nix
      ./flatpak.nix
      ./kdeconnect-ports.nix
      ./opengl.nix
      ./pipewire.nix
      ./system76-scheduler.nix
    ];

  home-manager.sharedModules = [
    # inject some additional config into the base home namespace
    # this extends the 'parent' config, and then the generic-linux specialization
    # is then activated as a layer over top.
    {
      imports = with self.homeModules; [
        discord
        kdeconnect
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
    }

    # we switch to the generic-linux module after loading this
  ];

  services = {
    gnome.gnome-remote-desktop.enable = true;
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = lib.meta.getExe pkgs.gnome.gnome-session;
  services.xrdp.openFirewall = true;
}

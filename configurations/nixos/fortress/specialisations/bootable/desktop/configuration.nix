{
  self,
  lib,
  pkgs,
  ...
}: {
  imports =
    [self.modules.generic.unfree]
    ++ [
      ./kdeconnect-ports.nix
      ./pipewire.nix
    ];

  hardware = rec {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = pkgs.stdenv.isx86_64;
    };
  };

  services = {
    gnome.gnome-remote-desktop.enable = true;
    system76-scheduler.enable = true;
    xrdp = {
      enable = true;
      defaultWindowManager = lib.meta.getExe pkgs.gnome-session;
      openFirewall = true;
    };
  };

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

  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.loader.grub.configurationLimit = 6;
}

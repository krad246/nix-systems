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
      ./yubikey.nix
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
    {
      imports = with self.homeModules; [
        discord
        kdeconnect
      ];
    }
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.loader.grub.configurationLimit = 6;
}

{
  services = {
    gnome.gnome-remote-desktop.enable = true;
  };

  networking.firewall.allowedTCPPorts = [3389];
}

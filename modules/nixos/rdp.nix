{
  services = {
    gnome.gnome-remote-desktop.enable = true;
  };

  networking.firewall = rec {
    allowedTCPPorts = [3389 3390];
    allowedUDPPorts = allowedTCPPorts;
  };
}

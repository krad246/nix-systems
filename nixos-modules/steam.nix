{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  hardware.steam-hardware.enable = true;

  systemd.tmpfiles.rules = [
    "d /games            777 nobody    nobody  - -"
  ];
}

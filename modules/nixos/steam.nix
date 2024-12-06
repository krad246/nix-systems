{
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;

    extest.enable = true;
    # protontricks.enable = true;

    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

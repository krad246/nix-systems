{ezModules, ...}: {
  imports = with ezModules; [
    dock
    finder
    pointer
    single-user
    ui-ux
  ];

  system.defaults = {
    smb = {NetBIOSName = "nixbook-air";};
  };

  networking = {
    hostName = "nixbook-air";
    localHostName = "nixbook-air";
    computerName = "nixbook-air";
  };
}

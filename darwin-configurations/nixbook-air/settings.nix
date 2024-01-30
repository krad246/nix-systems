{ezModules, ...}: let
  darwinModules = ezModules;
in {
  imports = with darwinModules; [
    dock
    finder
    single-user
    ui-ux
    pointer
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

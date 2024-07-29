{
  imports = [
    ../../darwin-modules/dock.nix
    ../../darwin-modules/finder.nix
    ../../darwin-modules/pointer.nix
    ../../darwin-modules/single-user.nix
    ../../darwin-modules/ui-ux.nix
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

{config, ...}: {
  imports = [
    ./auto-update.nix
    ./dark-mode.nix
    ./keyboard.nix
    ./menubar.nix
    ./touch-id.nix
    ./window-manager.nix
  ];

  system.defaults = {
    NSGlobalDomain = {
      NSDisableAutomaticTermination = false;
      NSDocumentSaveNewDocumentsToCloud = true;

      "com.apple.sound.beep.volume" = 0.5;
      "com.apple.springing.enabled" = true;
    };
  };

  networking = {
    localHostName = config.networking.hostName;
    computerName = config.networking.hostName;
  };
}

{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    auto-update
    dark-mode
    keyboard
    menubar
    touch-id
    window-manager
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

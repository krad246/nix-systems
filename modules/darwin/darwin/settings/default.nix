{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    auto-update
    dark-mode
    dock
    finder
    firewall
    keyboard
    menubar
    pointer
    single-user
    touch-id
    ui-ux
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

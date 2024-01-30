{config, ...}: {
  # Add ability to use TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;

      # Enable full keyboard access for all controls
      # (e.g. enable Tab in modal dialogs)
      AppleKeyboardUIMode = 3;

      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Automatic";
      AppleScrollerPagingBehavior = true;

      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticDashSubstitutionEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      NSAutomaticQuoteSubstitutionEnabled = true;
      NSAutomaticSpellingCorrectionEnabled = true;
      NSAutomaticWindowAnimationsEnabled = true;

      NSDisableAutomaticTermination = false;

      NSDocumentSaveNewDocumentsToCloud = true;

      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      NSTableViewDefaultSizeMode = 2;

      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;

      # Set a blazingly fast keyboard repeat rate
      InitialKeyRepeat = 12;
      KeyRepeat = 3;

      "com.apple.keyboard.fnState" = true;
      "com.apple.sound.beep.volume" = 0.5;
      "com.apple.springing.enabled" = true;

      _HIHideMenuBar = false;
    };

    smb.NetBIOSName = config.networking.hostName;
  };

  networking = {
    computerName = config.networking.hostName;
    localHostName = config.networking.hostName;
  };
}

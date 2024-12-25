{
  system = {
    defaults = {
      # disable fn key bc it's annoying
      hitoolbox.AppleFnUsageType = "Do Nothing";

      NSGlobalDomain = {
        # Enable full keyboard access for all controls
        # (e.g. enable Tab in modal dialogs)
        AppleKeyboardUIMode = 3;

        NSAutomaticCapitalizationEnabled = true;
        NSAutomaticDashSubstitutionEnabled = true;
        NSAutomaticPeriodSubstitutionEnabled = true;
        NSAutomaticQuoteSubstitutionEnabled = true;
        NSAutomaticSpellingCorrectionEnabled = true;
        NSAutomaticWindowAnimationsEnabled = true;

        # Set a blazingly fast keyboard repeat rate
        InitialKeyRepeat = 12;
        KeyRepeat = 3;

        # f1, f2 etc available
        "com.apple.keyboard.fnState" = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
    };
  };
}

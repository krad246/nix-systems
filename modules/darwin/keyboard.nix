{lib, ...}: {
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

        # f1, f2 etc available as default key behavior
        "com.apple.keyboard.fnState" = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
    };
  };

  home.activation.disableHotkeys = let
    hotkeys = [
      12
      15
      16
      163
      164
      17
      175
      18
      184
      19
      190
      20
      21
      22
      222
      223
      224
      23
      24
      25
      26
      28
      29
      30
      31
      36
      52
      53
      54
      60
      61
      79
      80
      81
      82
      98
    ];

    disables =
      map (key: "defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add ${
        toString key
      } '<dict><key>enabled</key><false/></dict>'")
      hotkeys;
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Disable hotkeys
      echo >&2 "hotkey suppression..."
      set -e
      ${lib.concatStringsSep "\n" disables}
    '';
}

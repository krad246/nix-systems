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

        # f1, f2 etc available as default key behavior
        "com.apple.keyboard.fnState" = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
    };
  };
}
// {
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
    AppleSymbolicHotKeys = {
      "61" = {
        value = {
          type = "standard";
          parameters = [
            32
            49
            786432
          ];
        };
        enabled = false;
      };

      "54" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            113
            8388608
          ];
        };
      };

      "218" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "225" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "55" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            107
            8912896
          ];
        };
      };
      "162" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            96
            9961472
          ];
        };
      };
      "232" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "163" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            124
            11272192
          ];
        };
      };
      "121" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            21
            262144
          ];
        };
      };
      "56" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            113
            8912896
          ];
        };
      };
      "219" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "226" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "57" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            100
            8650752
          ];
        };
      };
      "64" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            32
            49
            1048576
          ];
        };
      };
      "164" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "227" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "65" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            32
            49
            1572864
          ];
        };
      };
      "80" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            123
            8781824
          ];
        };
      };
      "59" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            96
            9437184
          ];
        };
      };
      "228" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "81" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            124
            10878976
          ];
        };
      };
      "82" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            124
            8781824
          ];
        };
      };
      "159" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            36
            262144
          ];
        };
      };
      "229" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "7" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            120
            8650752
          ];
        };
      };
      "118" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            18
            393216
          ];
        };
      };
      "119" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            19
            393216
          ];
        };
      };
      "120" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            20
            393216
          ];
        };
      };
      "10" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            96
            8650752
          ];
        };
      };
      "8" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            122
            8650752
          ];
        };
      };
      "9" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            96
            50
            1048576
          ];
        };
      };
      "11" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            97
            8650752
          ];
        };
      };
      "175" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "79" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            123
            10878976
          ];
        };
      };
      "12" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            122
            8650752
          ];
        };
      };
      "13" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            98
            8650752
          ];
        };
      };
      "190" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            113
            12
            8388608
          ];
        };
      };
      "20" = {
        enabled = false;
      };
      "21" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            56
            28
            1835008
          ];
        };
      };
      "22" = {
        enabled = false;
      };
      "15" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            56
            28
            1572864
          ];
        };
      };
      "184" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            53
            23
            1179648
          ];
        };
      };
      "30" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            52
            21
            1179648
          ];
        };
      };
      "23" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            92
            65535
            1572864
          ];
        };
      };
      "16" = {
        enabled = false;
      };
      "98" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            47
            44
            1179648
          ];
        };
      };
      "31" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            52
            21
            1441792
          ];
        };
      };
      "24" = {
        enabled = false;
      };
      "17" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            61
            24
            1572864
          ];
        };
      };
      "32" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            126
            10878976
          ];
        };
      };
      "25" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            46
            47
            1835008
          ];
        };
      };
      "18" = {
        enabled = false;
      };
      "179" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "33" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            125
            10878976
          ];
        };
      };
      "26" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            44
            43
            1835008
          ];
        };
      };
      "19" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            45
            27
            1572864
          ];
        };
      };
      "34" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            126
            10878976
          ];
        };
      };
      "27" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            96
            50
            1048576
          ];
        };
      };
      "222" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            126
            11272192
          ];
        };
      };
      "215" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "35" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            125
            10878976
          ];
        };
      };
      "28" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            51
            20
            1179648
          ];
        };
      };
      "36" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            99
            8388608
          ];
        };
      };
      "29" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            51
            20
            1441792
          ];
        };
      };
      "160" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            125
            11272192
          ];
        };
      };
      "223" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "216" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "37" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            103
            8519680
          ];
        };
      };
      "230" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "52" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            100
            2
            1572864
          ];
        };
      };
      "224" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "217" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "231" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "60" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            32
            49
            262144
          ];
        };
      };
      "53" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            107
            8388608
          ];
        };
      };
      "250" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            126
            8781824
          ];
        };
      };
      "251" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            125
            8781824
          ];
        };
      };
      "248" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            123
            8781824
          ];
        };
      };
      "249" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            124
            8781824
          ];
        };
      };
      "256" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            120
            7
            8781824
          ];
        };
      };
      "257" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
      "258" = {
        enabled = false;
        value = {
          type = "standard";
          parameters = [
            65535
            65535
            0
          ];
        };
      };
    };
  };
}

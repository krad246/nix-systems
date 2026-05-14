{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.input.keyboard = {
      layout = lib.options.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Primary desktop keyboard layout.";
      };

      functionKeysAsStandard = lib.options.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use F1, F2, etc. as standard function keys where the backend supports it.";
      };

      fullKeyboardAccess = lib.options.mkEnableOption "full keyboard access for all controls" // {default = true;};

      initialRepeat = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 12;
        description = "Initial keyboard repeat delay. Lower is faster.";
      };

      repeat = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 3;
        description = "Keyboard repeat interval. Lower is faster.";
      };

      numlock = lib.options.mkEnableOption "numlock" // {default = true;};

      textSubstitutions = {
        capitalization = lib.options.mkEnableOption "automatic capitalization" // {default = true;};
        dash = lib.options.mkEnableOption "automatic dash substitution" // {default = true;};
        period = lib.options.mkEnableOption "automatic period substitution" // {default = true;};
        quote = lib.options.mkEnableOption "automatic quote substitution" // {default = true;};
        spelling = lib.options.mkEnableOption "automatic spelling correction" // {default = true;};
      };
    };
  };
}

{
  inputs,
  self,
  osConfig,
  pkgs,
  ...
}: let
  inherit (inputs) mac-app-util;
in {
  imports = with self.homeModules;
    ([agenix] ++ [colima] ++ [discord kitty vscode])
    ++ [mac-app-util.homeManagerModules.default];

  home = {
    packages = with pkgs; [mas m-cli];
  };

  targets.darwin = {
    currentHostDefaults = {
      "com.apple.controlcenter" = {
      };
    };

    defaults = {
      NSGlobalDomain = {
      };

      "com.apple.Safari" = {
      };

      "com.apple.desktopservices" = {
      };

      "com.apple.dock" = {
      };

      "com.apple.finder" = {
        inherit (osConfig.system.defaults.finder) AppleShowAllFiles;
        inherit (osConfig.system.defaults.finder) FXRemoveOldTrashItems;
        inherit (osConfig.system.defaults.finder) ShowPathbar;
        inherit (osConfig.system.defaults.finder) ShowStatusBar;
      };

      "com.apple.menuextra.battery" = {
      };

      "com.apple.menuextra.clock" = {
      };
    };

    keybindings = {
    };

    search = "Google";
  };

  specialisation = {
    default = {
      configuration = _: {
        imports = [self.darwinModules.darwin];
      };
    };
  };
}

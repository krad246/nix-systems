{
  inputs,
  self,
  osConfig,
  pkgs,
  ...
}: let
  inherit (inputs) mac-app-util;
in {
  imports =
    [mac-app-util.homeManagerModules.default]
    ++ (with self.homeModules; [
      discord
      kitty
      vscode
      zen
    ]);

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

  # overwrite default specialisation
  specialisation = {
    default.configuration = {
      imports = [self.homeModules.darwin];
    };
  };
}

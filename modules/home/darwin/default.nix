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
      agenix
      discord
      kitty
      vscode
    ]);

  nix.settings.sandbox = false;

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
        imports = [self.homeModules.darwin];
      };
    };
  };
}

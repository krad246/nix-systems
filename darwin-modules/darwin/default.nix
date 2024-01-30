{ezModules, ...}: let
  darwinModules = ezModules;
in {
  imports = [./nix-core.nix ./system-packages.nix ./system-settings.nix] ++ [darwinModules.homebrew];
}

{ezModules, ...}: let
  homeModules = ezModules;
in {
  imports =
    (with homeModules; [
      bash
      bat
      bottom
      cachix
      coreutils
      colima
      direnv
      git
      nerdfonts
      nvim
      ripgrep
      starship
      zoxide
      zsh
    ])
    ++ [./settings.nix];
}

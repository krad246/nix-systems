{ezModules, ...}: {
  imports =
    (with ezModules; [
      bash
      bat
      bottom
      coreutils
      colima
      direnv
      git
      nvim
      ripgrep
      starship
      zoxide
      zsh
    ])
    ++ [./settings.nix];
}

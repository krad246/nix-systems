{ezModules, ...}: {
  imports = with ezModules; [
    bash
    bat
    coreutils
    direnv
    git
    zsh
    nvim
    starship
  ];

  programs = {
    bottom.enable = true;
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}

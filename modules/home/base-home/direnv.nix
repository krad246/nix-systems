{config, ...}: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
  };
}

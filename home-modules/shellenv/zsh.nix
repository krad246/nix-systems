{config, ...}: {
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    autocd = true;

    history = {
      path = "${config.xdg.cacheHome}/zsh/history";
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      share = false;
    };

    plugins = [];
  };
}

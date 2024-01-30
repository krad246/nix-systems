{config, ...}: {
  programs.zsh = {
    enable = true;

    enableAutosuggestions = true;
    enableCompletion = true;

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

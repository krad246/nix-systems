{
  programs.bash = {
    enable = true;

    enableCompletion = true;
    enableVteIntegration = true;

    initExtra = ''
      set -o vi

      bind -r "\C-p"
      bind -r "\C-n"

      bind -r "\C-h"
    '';

    historyControl = [
      "ignoreboth"
      "erasedups"
    ];

    historyIgnore = ["exit" "reload"];
  };
}

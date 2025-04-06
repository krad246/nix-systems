{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    initExtra = ''
      set -o vi
    '';

    historyControl = [
      "ignoreboth"
      "erasedups"
    ];

    historyIgnore = ["exit" "reload"];
  };
}

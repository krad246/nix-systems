{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    initExtra = ''
      set -o vi
    '';

    historyControl = ["erasedups"];
    historyIgnore = ["exit" "reload"];
  };
}

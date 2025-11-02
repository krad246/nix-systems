{
  config,
  lib,
  ...
}: {
  programs.bash = {
    enable = true;

    enableCompletion = true;
    enableVteIntegration = true;

    initExtra = ''
      set -o vi

      bind -r "\C-p"
      bind -r "\C-n"

      bind -r "\C-h"

      function y() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      	${lib.meta.getExe config.programs.yazi.package} "$@" --cwd-file="$tmp"
      	IFS= read -r -d \'\' cwd < "$tmp"
      	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
      	rm -f -- "$tmp"
      }
    '';

    historyControl = [
      "ignoreboth"
      "erasedups"
    ];

    historyIgnore = ["exit" "reload"];
  };
}

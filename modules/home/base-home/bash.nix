{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.bash = {
    enable = true;

    enableCompletion = true;
    enableVteIntegration = true;

    initExtra = ''
      set -o vi

      # menu-complete-backward
      # bind -r "\C-p"

      # menu-complete-forward
      # bind -r "\C-n"

      # backward-delete-char
      bind -r "\C-h"
      # bind -r "\C-?"

      function y() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      	${lib.meta.getExe config.programs.yazi.package} "$@" --cwd-file="$tmp"
      	IFS= read -r -d \'\' cwd < "$tmp"
      	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
      	rm -f -- "$tmp"
      }

      ${lib.strings.optionalString (config.programs.kitty.enable && config.programs.fzf.enable) ''
        export FZF_PREVIEW_IMAGE_HANDLER=kitty
      ''}
    '';

    historyControl = [
      "ignoreboth"
      "erasedups"
    ];

    historyIgnore = ["exit" "reload"];

    shellAliases = let
      inherit (lib) meta;
    in {
      reload = ''
        exec ${meta.getExe config.programs.bash.package} \
          --rcfile <(${meta.getExe' pkgs.coreutils "echo"} \
              'source ${config.home.homeDirectory}/.bashrc; \
              ${meta.getExe pkgs.direnv} reload')
      '';
      tldr = meta.getExe pkgs.tldr;
    };
  };
}

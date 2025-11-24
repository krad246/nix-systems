{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) meta strings;
in {
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

      ${strings.optionalString config.programs.yazi.enable ''
        function y() {
        	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        	${meta.getExe config.programs.yazi.package} "$@" --cwd-file="$tmp"
        	IFS= read -r -d \'\' cwd < "$tmp"
        	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        	rm -f -- "$tmp"
        }
      ''}

      ${strings.optionalString (config.programs.kitty.enable && config.programs.fzf.enable) ''
        export FZF_PREVIEW_IMAGE_HANDLER=kitty
      ''}
    '';

    historyControl = [
      "ignoreboth"
      "erasedups"
    ];

    historyIgnore = ["exit" "reload"];

    shellAliases = {
      reload = ''
        exec ${meta.getExe config.programs.bash.package} \
          --rcfile <(${meta.getExe' pkgs.coreutils "echo"} \
              'source ${config.home.homeDirectory}/.bashrc; \
              ${strings.optionalString config.programs.direnv.enable ''
          ${meta.getExe config.programs.direnv.package} reload
        ''}')
      '';
      tldr = meta.getExe pkgs.tldr;
    };
  };
}

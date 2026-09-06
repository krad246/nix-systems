{lib, ...}: {
  flake.modules.homeManager.shell = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.shell;
    toReadlineBinding = binding: let
      parsed = builtins.match "(ctrl|alt)-(.)" binding;
    in
      if parsed == null
      then binding
      else if builtins.elemAt parsed 0 == "ctrl"
      then "\\C-${builtins.elemAt parsed 1}"
      else "\\e${builtins.elemAt parsed 1}";
  in {
    options.shell.backends.bash = {
      enable = lib.options.mkEnableOption "Whether to manage `bash`.";
      integrations = {
        batpipe.enable =
          lib.options.mkEnableOption "Whether to enable the `batpipe` integration for `bash`."
          // {
            internal = true;
          };
        direnv.enable =
          lib.options.mkEnableOption "Whether to enable the `direnv` integration for `bash`."
          // {
            default = cfg.integrations.direnv.enable;
          };
        fzf.enable =
          lib.options.mkEnableOption "Whether to enable the `fzf` integration for `bash`."
          // {
            default = cfg.integrations.fzf.enable;
          };
        lsd.enable =
          lib.options.mkEnableOption "Whether to enable the `lsd` integration for `bash`."
          // {
            default = cfg.integrations.lsd.enable;
          };
        kitty.enable =
          lib.options.mkEnableOption "Whether to enable the `kitty` integration for `bash`."
          // {
            default = cfg.integrations.kitty.enable;
          };
        starship.enable =
          lib.options.mkEnableOption "Whether to enable the `starship` integration for `bash`."
          // {
            default = cfg.integrations.starship.enable;
          };
        yazi.enable =
          lib.options.mkEnableOption "Whether to enable the `yazi` integration for `bash`."
          // {
            default = cfg.integrations.yazi.enable;
          };
        zoxide.enable =
          lib.options.mkEnableOption "Whether to enable the `zoxide` integration for `bash`."
          // {
            default = cfg.integrations.zoxide.enable;
          };
      };
    };

    config = lib.modules.mkIf cfg.backends.bash.enable (lib.modules.mkMerge [
      {
        programs = {
          bash = {
            enable = true;
            enableCompletion = true;
            enableVteIntegration = true;

            initExtra = ''
              set -o vi
            '';

            historyControl = [
              "erasedups"
              "ignoreboth"
            ];

            historyIgnore = [
              "exit"
            ];
          };
        };
      }
      (lib.modules.mkIf cfg.backends.bash.integrations.batpipe.enable
        {
          programs.bash.initExtra = ''
            eval "$(${lib.meta.getExe pkgs.bat-extras.batpipe})"
          '';
        })
      (lib.modules.mkIf cfg.backends.bash.integrations.direnv.enable
        {
          programs.direnv = {
            enableBashIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.bash.integrations.fzf.enable
        {
          programs.fzf = {
            enableBashIntegration = true;
          };

          programs.bash.initExtra = let
            bindWidget = binding: widget: ''
              for keymap in emacs-standard vi-command vi-insertion; do
                bind -m "$keymap" -x '"${toReadlineBinding binding}": ${widget}'
              done
            '';
          in
            lib.strings.concatStrings [
              (lib.strings.optionalString config.picker.sources.files.enable
                (bindWidget config.picker.bindings.shell.files "fzf-file-widget"))
              (lib.strings.optionalString config.picker.sources.directories.enable
                (bindWidget config.picker.bindings.shell.directories "fzf-cd-widget"))
              (lib.strings.optionalString config.picker.sources.history.enable
                (bindWidget config.picker.bindings.shell.history "fzf-history-widget"))
            ];
        })
      (lib.modules.mkIf cfg.backends.bash.integrations.lsd.enable
        {
          programs.lsd = {
            enableBashIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.bash.integrations.kitty.enable
        {
          programs.kitty = {
            shellIntegration.enableBashIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.bash.integrations.starship.enable
        {
          programs.starship = {
            enableBashIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.bash.integrations.yazi.enable
        {
          programs.bash.initExtra = ''
            function y() {
            	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
            	yazi "$@" --cwd-file="$tmp"
            	IFS= read -r -d \'\' cwd < "$tmp"
            	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
            	rm -f -- "$tmp"
            }
          '';

          programs.yazi = {
            enableBashIntegration = true;
          };
        })
      (lib.modules.mkIf cfg.backends.bash.integrations.zoxide.enable
        {
          programs.zoxide = {
            enableBashIntegration = true;
          };
        })
    ]);
  };
}

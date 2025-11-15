{
  config,
  lib,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = ''
      ${lib.meta.getExe config.programs.fd.package}
    '';

    fileWidgetCommand = ''
      ${lib.meta.getExe config.programs.fd.package}
    '';

    fileWidgetOptions = let
      args = lib.cli.toGNUCommandLineShell {} {
        height = "~100%";
        layout = "reverse-list";

        multi = true;
        highlight-line = true;
        cycle = true;
        wrap = true;
        track = true;
        filepath-word = true;

        preview = ''
          ${lib.meta.getExe config.programs.bat.package} --color=always --style=numbers {}
        '';
        preview-window = "up";

        bind = [
          # TODO: consider become(); it's a bit tricky with TTY forwarding though
          # FIXME: ctrl-z is fundamentally broken with keybinds like these because it causes fzf to deadlock
          # "ctrl-o:execute(find {+} -type f -print0 | xargs --no-run-if-empty -0 -o $EDITOR)"
          # "ctrl-v:execute(find {+} -type f -print0 | xargs --no-run-if-empty -0 -o ${lib.meta.getExe config.programs.bat.package})"
        ];

        scheme = "path";
      };
    in [
      args
    ];

    historyWidgetOptions = let
      args = lib.cli.toGNUCommandLineShell {} {
        height = "~100%";
        # layout = "reverse-list";

        multi = true;
        highlight-line = true;
        cycle = true;
        wrap = true;
        track = true;
        filepath-word = true;

        scheme = "history";
      };
    in [
      args
    ];

    changeDirWidgetCommand = ''
      ${lib.meta.getExe config.programs.fd.package} --type d
    '';

    changeDirWidgetOptions = let
      args = lib.cli.toGNUCommandLineShell {} {
        height = "~100%";
        layout = "reverse-list";

        multi = true;
        highlight-line = true;
        cycle = true;
        wrap = true;
        track = true;
        filepath-word = true;

        scheme = "path";
      };
    in [args];
  };
}

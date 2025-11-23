{
  config,
  lib,
  pkgs,
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
          ${lib.meta.getExe (pkgs.unstable.fzf-preview.override {bat = config.programs.bat.package;})} {}
        '';
        preview-window = "up";

        bind = let
          wrap = key: cmd: let
            script = pkgs.writeShellApplication {
              name = "fzf-${key}-nosusp";
              text = ''
                stty susp undef
                find "$@" -type f -print0 | \
                  xargs --no-run-if-empty -0 -o "${cmd}"
              '';
            };
            bin = lib.meta.getExe script;
          in "${key}:execute(${bin} {+})";
        in [
          (wrap "ctrl-o" (let
            hx-nosuspend = pkgs.symlinkJoin rec {
              name = "hx";
              paths = [config.programs.helix.package];
              buildInputs = [pkgs.makeWrapper];

              # Wrap helix to be started with ctrl-z disabled.
              postBuild = let
                # Deep rewrite: any attribute named "C-z" becomes "no_op"
                # TODO: there must be a library function that does this
                noCZ = let
                  stripCZ = let
                    go = v:
                      if builtins.isAttrs v
                      then
                        lib.mapAttrs
                        (
                          name: val:
                            if name == "C-z"
                            then "no_op"
                            else go val
                        )
                        v
                      else if lib.isList v
                      then map go v
                      else v;
                  in
                    go;
                in
                  stripCZ config.programs.helix.settings;
              in ''
                wrapProgram $out/bin/hx --add-flags '-c ${let
                  tomlFormat = pkgs.formats.toml {};
                in
                  tomlFormat.generate "hx-nosusp-config.toml" noCZ}'
              '';
            };
          in
            lib.meta.getExe hx-nosuspend))
          (wrap "ctrl-v" (lib.meta.getExe config.programs.bat.package))
          "ctrl-r:reload(eval \"$FZF_CTRL_T_COMMAND\")"
          "ctrl-/:change-preview-window(hidden|up)"
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

        preview = ''
          ${lib.meta.getExe (pkgs.unstable.fzf-preview.override {bat = config.programs.bat.package;})} {}
        '';
        preview-window = "up";
      };
    in [args];
  };
}

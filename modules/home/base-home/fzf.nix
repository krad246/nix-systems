{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) cli meta strings;
in {
  programs.fzf = let
    # Construct an FZF keybind string
    keybind = {
      key,
      action,
    }: "'${key}:${action}'";

    # Construct an FZF action that handles FZF multi-select
    # Pass the list of files selected to an arbitrary command.
    on-multiselect = {
      key,
      command,
    }:
      keybind {
        inherit key;
        action = let
          script = pkgs.writeShellApplication {
            name = "fzf-${key}-on-multiselect";
            text = command;
          };
        in "execute(find {+} -type f -print0 | xargs --no-run-if-empty -0 -o ${meta.getExe script})";
      };

    defaultArgs = {
      height = "~100%";
      multi = true;
      highlight-line = true;
      cycle = true;
      wrap = true;
      track = true;
      filepath-word = true;
      bind = [
      ];
    };

    fileArgs = rec {
      layout = "reverse-list";
      scheme = "path";

      preview-window = "up";
      preview = let
        fzf-preview = pkgs.unstable.fzf-preview.override {
          bat = config.programs.bat.package;
        };
      in "'${meta.getExe fzf-preview} {}'";

      bind =
        defaultArgs.bind
        ++ [
          (keybind {
            key = "ctrl-/";
            action = "change-preview-window(hidden|${preview-window})";
          })
          (keybind {
            key = "ctrl-r";
            action = "reload(eval '${config.programs.fzf.defaultCommand}')";
          })
        ];
    };
  in {
    enable = true;
    enableBashIntegration = true;

    changeDirWidgetCommand = strings.concatStringsSep " " [
      (meta.getExe config.programs.fd.package)
      (cli.toGNUCommandLineShell {} {
        type = "d";
      })
    ];

    changeDirWidgetOptions = cli.toGNUCommandLine {} (defaultArgs // fileArgs);

    defaultCommand = meta.getExe config.programs.fd.package;
    defaultOptions = cli.toGNUCommandLine {} defaultArgs;

    fileWidgetOptions = cli.toGNUCommandLine {} (
      defaultArgs
      // fileArgs
      // {
        bind =
          fileArgs.bind
          ++ [
            (on-multiselect {
              key = "ctrl-v";
              command = ''
                stty susp undef
                exec ${strings.concatStringsSep " " [
                  (meta.getExe config.programs.bat.package)
                  (cli.toGNUCommandLineShell {} {
                    paging = "always";
                  })
                ]} "$@"
              '';
            })
            (on-multiselect {
              key = "ctrl-o";
              command = let
                hx-no-ctrl-z = pkgs.symlinkJoin {
                  name = "hx";
                  paths = [config.programs.helix.package];
                  buildInputs = [pkgs.makeWrapper];

                  # nosusp helix to be started with ctrl-z disabled.
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
              in ''
                stty susp undef
                exec ${meta.getExe hx-no-ctrl-z} "$@"
              '';
            })
          ];
      }
    );

    historyWidgetOptions = cli.toGNUCommandLine {} (defaultArgs
      // {
        scheme = "history";
      });
  };
}

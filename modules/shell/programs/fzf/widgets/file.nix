{lib, ...}: {
  flake.modules.homeManager.fzf = {
    config,
    pkgs,
    ...
  }: let
    # inherit (pkgs) lib;
    inherit (lib) cli meta strings;
  in {
    programs.fzf = let
      inherit (config) picker;
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
      };

      fileArgs = let
        previewWindow = "up";
      in
        {
          layout = "reverse-list";
          scheme = "path";
          bind =
            lib.lists.optionals picker.actions.preview.enable [
              (keybind {
                key = picker.bindings.picker.togglePreview;
                action = "change-preview-window(hidden|${previewWindow})";
              })
            ]
            ++ lib.lists.optionals picker.sources.files.enable [
              (keybind {
                key = picker.bindings.picker.reload;
                action = "reload(${picker.sources.files.command})";
              })
            ];
        }
        // lib.attrsets.optionalAttrs picker.actions.preview.enable {
          preview-window = previewWindow;
          preview = strings.escapeShellArg [
            picker.actions.preview.command
            "{}"
          ];
        };
    in {
      fileWidgetCommand = lib.strings.optionalString picker.sources.files.enable picker.sources.files.command;
      fileWidgetOptions = cli.toGNUCommandLine {} (
        defaultArgs
        // fileArgs
        // {
          bind =
            fileArgs.bind
            ++ lib.lists.optionals picker.actions.view.enable [
              (on-multiselect {
                key = picker.bindings.picker.view;
                command = ''
                  stty susp undef
                  exec ${picker.actions.view.command} "$@"
                '';
              })
            ]
            ++ lib.lists.optionals picker.actions.edit.enable [
              (on-multiselect {
                key = picker.bindings.picker.edit;
                command = ''
                  stty susp undef
                  exec ${picker.actions.edit.command} "$@"
                '';
              })
            ];
        }
      );
    };
  };
}

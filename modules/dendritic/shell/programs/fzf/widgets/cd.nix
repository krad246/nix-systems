{lib, ...}: {
  flake.modules.homeManager.fzf = {config, ...}: {
    programs.fzf = let
      inherit (config) picker;
      # Construct an FZF keybind string
      keybind = {
        key,
        action,
      }: "'${key}:${action}'";

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
            ++ lib.lists.optionals picker.sources.directories.enable [
              (keybind {
                key = picker.bindings.picker.reload;
                action = "reload(${picker.sources.directories.command})";
              })
            ];
        }
        // lib.attrsets.optionalAttrs picker.actions.preview.enable {
          preview-window = previewWindow;
          preview = lib.strings.escapeShellArg [
            picker.actions.preview.command
            "{}"
          ];
        };
    in {
      changeDirWidgetOptions = config.programs.fzf.defaultOptions ++ (lib.cli.toGNUCommandLine {} fileArgs);
      changeDirWidgetCommand = lib.strings.optionalString picker.sources.directories.enable picker.sources.directories.command;
    };
  };
}

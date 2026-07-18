{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.fzf = {
    config,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.fd];

    programs.fzf = let
      inherit (config) picker;
      # Construct an FZF keybind string
      keybind = {
        key,
        action,
      }: "'${key}:${action}'";

      fileArgs = rec {
        layout = "reverse-list";
        scheme = "path";

        preview-window = "up";
        preview = let
          fzf-preview = pkgs.unstable.fzf-preview.override {
            bat = config.programs.bat.package;
          };
        in
          lib.strings.escapeShellArg [
            (lib.meta.getExe fzf-preview)
            "{}"
          ];

        bind = [
          (keybind {
            key = picker.bindings.picker.togglePreview;
            action = "change-preview-window(hidden|${preview-window})";
          })
          (keybind {
            key = picker.bindings.picker.reload;
            action = "reload(eval '${config.programs.fzf.defaultCommand}')";
          })
        ];
      };
    in {
      changeDirWidgetOptions = config.programs.fzf.defaultOptions ++ (lib.cli.toGNUCommandLine {} fileArgs);
      changeDirWidgetCommand = lib.strings.concatStringsSep " " [
        (lib.meta.getExe picker.sources.directories.package)
        (lib.cli.toGNUCommandLineShell {} picker.sources.directories.arguments)
      ];
    };
  };
}

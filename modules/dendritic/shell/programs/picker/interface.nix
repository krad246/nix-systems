{lib, ...}: {
  flake.modules.homeManager.picker = {
    options.picker = let
      operation = description: {
        enable = lib.options.mkEnableOption description // {default = true;};
        command = lib.options.mkOption {
          type = lib.types.str;
          default = "";
          description = "Command implementing ${description}.";
        };
      };
    in {
      backends.fzf.enable = lib.options.mkEnableOption "FZF picker backend";

      sources = {
        files = operation "file picker candidate production";
        directories = operation "directory picker candidate production";
        history = operation "shell history candidate production";
      };

      actions = {
        preview = operation "selected-path previewing";
        view = operation "selected-path viewing";
        edit = operation "selected-path editing";
      };

      bindings = {
        shell = {
          files = lib.options.mkOption {
            type = lib.types.str;
            default = "ctrl-t";
            description = "Shell binding for selecting files.";
          };
          directories = lib.options.mkOption {
            type = lib.types.str;
            default = "alt-c";
            description = "Shell binding for changing directories.";
          };
          history = lib.options.mkOption {
            type = lib.types.str;
            default = "ctrl-r";
            description = "Shell binding for selecting command history.";
          };
        };

        picker = {
          togglePreview = lib.options.mkOption {
            type = lib.types.str;
            default = "ctrl-/";
            description = "Picker binding for toggling the preview pane.";
          };
          reload = lib.options.mkOption {
            type = lib.types.str;
            default = "ctrl-r";
            description = "Picker binding for reloading candidates.";
          };
          view = lib.options.mkOption {
            type = lib.types.str;
            default = "ctrl-v";
            description = "Picker binding for viewing selected files.";
          };
          edit = lib.options.mkOption {
            type = lib.types.str;
            default = "ctrl-o";
            description = "Picker binding for editing selected files.";
          };
        };
      };
    };
  };
}

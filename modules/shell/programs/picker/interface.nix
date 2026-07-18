{lib, ...}: {
  flake.modules.homeManager.picker = {pkgs, ...}: {
    options.picker = {
      backends.fzf.enable = lib.options.mkEnableOption "FZF picker backend";

      sources = {
        files = {
          package = lib.options.mkPackageOption pkgs "fd" {};
          arguments = lib.options.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
            description = "Arguments for producing file picker candidates.";
          };
        };

        directories = {
          package = lib.options.mkPackageOption pkgs "fd" {};
          arguments = lib.options.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default.type = "d";
            description = "Arguments for producing directory picker candidates.";
          };
        };
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

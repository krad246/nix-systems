{lib, ...}: {
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      darwinLaunchOptions = ["--single-instance"];

      shellIntegration = {
        mode = "enabled";
      };

      settings = {
        scrollbar = "scrolled-and-hovered";
        scrollback_pager_history_size = 1;
        scrollback_fill_enlarged_window = "yes";

        show_hyperlink_targets = "yes";

        copy_on_select = "clipboard";

        strip_trailing_spaces = "smart";

        enabled_layouts = lib.strings.concatStringsSep "," [
          "fat"
          "tall"
          # "splits"
          "vertical"
          "horizontal"
          "stack"
          "grid"
        ];

        confirm_os_window_close = 0;
        macos_option_as_alt = "yes";
      };
    };
  };
}

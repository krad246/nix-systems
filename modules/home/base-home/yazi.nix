{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      manager = {
        # ratio
        sort_by = "natural";
        sort_sensitive = true;
        sort_dir_first = false;
        sort_translit = true;
        show_hidden = true;
        show_symlink = true;
        mouse_events = [
          "click"
          "scroll"
          "touch"
          "move"
          "drag"
        ];
      };

      preview = {
        wrap = "yes";
        tab_size = 4;
      };

      input = {
        cursor_blink = true;
      };
    };

    keymap = {
      manager = {
        prepend_keymap = [
          {
            on = "<C-[>";
            run = "noop";
          }
          {
            on = "<Enter>";
            run = "noop";
          }
          {
            on = "<S-Enter>";
            run = "noop";
          }
        ];
      };
    };
  };
}

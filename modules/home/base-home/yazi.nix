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
        title_format = "{cwd}";
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
            run = "tab_switch --relative -1";
          }
          {
            on = "<C-]>";
            run = "tab_switch --relative 1";
          }
          {
            on = "{";
            run = "noop";
          }
          {
            on = "}";
            run = "noop";
          }
          {
            on = "<C-c>";
            run = "noop";
          }
          {
            on = "<C-w>";
            run = "close";
          }
          {
            on = "<C-n>";
            run = "tab_create --current";
          }
          {
            on = "<C-p>";
            run = "search --via=fd";
          }
          {
            on = "<C-F>";
            run = "search --via=rg";
          }
          {
            on = "<C-?>";
            run = "search --via=rg";
          }
          {
            on = "s";
            run = "noop";
          }
          {
            on = "S";
            run = "noop";
          }
          # {
          #   on = ["c" "c"];
          #   run = "noop";
          # }
          # {
          #   on = ["c" "d"];
          #   run = "noop";
          # }
          # {
          #   on = ["c" "f"];
          #   run = "noop";
          # }
          # {
          #   on = ["c" "n"];
          #   run = "noop";
          # }
          # {
          #   on = "<Enter>";
          #   run = "noop";
          # }
          # {
          #   on = "<S-Enter>";
          #   run = "noop";
          # }
          {
            on = "1";
            run = "noop";
          }
          {
            on = "2";
            run = "noop";
          }
          {
            on = "3";
            run = "noop";
          }
          {
            on = "4";
            run = "noop";
          }
          {
            on = "5";
            run = "noop";
          }
          {
            on = "6";
            run = "noop";
          }
          {
            on = "7";
            run = "noop";
          }
          {
            on = "8";
            run = "noop";
          }
          {
            on = "9";
            run = "noop";
          }
          {
            on = "[";
            run = "noop";
          }
          {
            on = "]";
            run = "noop";
          }
        ];

        append_keymap = [
        ];
      };
    };
  };
}

{config, ...}: {
  programs.yazi = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;

    settings = rec {
      mgr = manager;
      manager = {
        ratio = [2 2 4];
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
        # title_format = "{cwd}";
      };

      preview = {
        wrap = "yes";
        tab_size = 4;
      };

      input = {
        cursor_blink = true;
      };
    };

    keymap = rec {
      mgr = manager;
      manager = {
        prepend_keymap = [
          {
            on = "<C-q>";
            run = "quit";
            desc = "Quit the process";
          }
          {
            on = "<C-c>";
            run = "noop";
          }
          {
            on = "<C-w>";
            run = "close";
            desc = "Close the current tab, or quit if it's last";
          }

          # {
          #   on = "o";
          #   run = "open --hovered";
          #   desc = "Open selected files";
          # }
          # {
          #   on = "O";
          #   run = "open --interactive --hovered";
          #   desc = "Open selected files interactively";
          # }
          # {
          #   on = "<Enter>";
          #   run = "open --hovered";
          #   desc = "Open selected files";
          # }
          # {
          #   on = "<S-Enter>";
          #   run = "open --interactive --hovered";
          #   desc = "Open selected files interactively";
          # }
          {
            on = "s";
            run = "search --via=fd";
            desc = "Search files by name via fd";
          }
          {
            on = "<C-p>";
            run = "search --via=fd";
            desc = "Search files by name via fd";
          }
          {
            on = "S";
            run = "search --via=rg";
            desc = "Search files by content via ripgrep";
          }
          {
            on = "<C-F>";
            run = "search --via=rg";
            desc = "Search files by content via ripgrep";
          }
          {
            on = "<C-?>";
            run = "search --via=rg";
            desc = "Search files by content via ripgrep";
          }
          {
            on = "<C-s>";
            run = "noop";
          }
          {
            on = "<A-c>";
            run = "plugin fzf";
            desc = "Jump to a file/directory via fzf";
          }
          {
            on = "z";
            run = "plugin zoxide";
            desc = "Jump to a directory via zoxide";
          }
          {
            on = "Z";
            run = "noop";
          }

          {
            on = ["m" "s"];
            run = "noop";
          }
          {
            on = ["m" "p"];
            run = "noop";
          }
          {
            on = ["m" "b"];
            run = "noop";
          }
          {
            on = ["m" "m"];
            run = "noop";
          }
          {
            on = ["m" "o"];
            run = "noop";
          }
          {
            on = ["m" "n"];
            run = "noop";
          }
          {
            on = ["<C-m>" "s"];
            run = "linemode size";
            desc = "Linemode: size";
          }
          {
            on = ["<C-m>" "p"];
            run = "linemode permissions";
            desc = "Linemode: permissions";
          }
          {
            on = ["<C-m>" "b"];
            run = "linemode btime";
            desc = "Linemode: btime";
          }
          {
            on = ["<C-m>" "m"];
            run = "linemode mtime";
            desc = "Linemode: mtime";
          }
          {
            on = ["<C-m>" "o"];
            run = "linemode owner";
            desc = "Linemode: owner";
          }
          {
            on = ["<C-m>" "n"];
            run = "linemode none";
            desc = "Linemode: none";
          }

          {
            on = ["c" "c"];
            run = "noop";
          }
          {
            on = ["c" "d"];
            run = "noop";
          }
          {
            on = ["c" "f"];
            run = "noop";
          }
          {
            on = ["c" "n"];
            run = "noop";
          }
          {
            on = ["<C-c>" "c"];
            run = "copy path";
            desc = "Copy the file path";
          }
          {
            on = ["<C-c>" "d"];
            run = "copy dirname";
            desc = "Copy the directory path";
          }
          {
            on = ["<C-c>" "f"];
            run = "copy filename";
            desc = "Copy the filename";
          }
          {
            on = ["<C-c>" "n"];
            run = "copy name_without_ext";
            desc = "Copy the filename without extension";
          }

          {
            on = ["," "m"];
            run = "noop";
          }
          {
            on = ["," "M"];
            run = "noop";
          }
          {
            on = ["," "b"];
            run = "noop";
          }
          {
            on = ["," "B"];
            run = "noop";
          }
          {
            on = ["," "e"];
            run = "noop";
          }
          {
            on = ["," "E"];
            run = "noop";
          }
          {
            on = ["," "a"];
            run = "noop";
          }
          {
            on = ["," "A"];
            run = "noop";
          }
          {
            on = ["," "n"];
            run = "noop";
          }
          {
            on = ["," "N"];
            run = "noop";
          }
          {
            on = ["," "s"];
            run = "noop";
          }
          {
            on = ["," "S"];
            run = "noop";
          }
          {
            on = ["," "r"];
            run = "noop";
          }
          {
            on = ["<C-s>" "m"];
            run = ["sort mtime --reverse=no" "linemode mtime"];
            desc = "Sort by modified time";
          }
          {
            on = ["<C-s>" "M"];
            run = ["sort mtime --reverse" "linemode mtime"];
            desc = "Sort by modified time (reverse)";
          }
          {
            on = ["<C-s>" "b"];
            run = ["sort btime --reverse=no" "linemode btime"];
            desc = "Sort by birth time";
          }
          {
            on = ["<C-s>" "B"];
            run = ["sort btime --reverse" "linemode btime"];
            desc = "Sort by birth time (reverse)";
          }
          {
            on = ["<C-s>" "e"];
            run = ["sort extension --reverse=no"];
            desc = "Sort by extension";
          }
          {
            on = ["<C-s>" "E"];
            run = ["sort extension --reverse"];
            desc = "Sort by extension (reverse)";
          }
          {
            on = ["<C-s>" "a"];
            run = ["sort alphabetical --reverse=no"];
            desc = "Sort alphabetically";
          }
          {
            on = ["<C-s>" "A"];
            run = ["sort alphabetical --reverse"];
            desc = "Sort alphabetically (reverse)";
          }
          {
            on = ["<C-s>" "n"];
            run = ["sort natural --reverse=no"];
            desc = "Sort naturally";
          }
          {
            on = ["<C-s>" "N"];
            run = ["sort natural --reverse"];
            desc = "Sort naturally (reverse)";
          }
          {
            on = ["<C-s>" "s"];
            run = ["sort size --reverse=no" "linemode size"];
            desc = "Sort by size";
          }
          {
            on = ["<C-s>" "S"];
            run = ["sort size --reverse" "linemode size"];
            desc = "Sort by size (reverse)";
          }

          {
            on = "<C-g>";
            run = "cd --interactive";
            desc = "Jump interactively";
          }

          {
            on = "<C-n>";
            run = "tab_create --current";
            desc = "Create a new tab with CWD";
          }
          {
            on = "t";
            run = "tab_create --current";
            desc = "Create a new tab with CWD";
          }

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
          {
            on = "<C-[>";
            run = "tab_switch --relative -1";
            desc = "Switch to previous tab";
          }
          {
            on = "<C-]>";
            run = "tab_switch --relative 1";
            desc = "Switch to next tab";
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
            on = "w";
            run = "noop";
          }
          {
            on = "<C-t>";
            run = "tasks:show";
            desc = "Show task manager";
          }
        ];

        append_keymap = [
        ];
      };
    };
  };
}

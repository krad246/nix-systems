{
  lib,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    darwinLaunchOptions = ["--single-instance"];
    shellIntegration = {
      mode = "enabled";
      enableBashIntegration = true;
    };
    themeFile = "GruvboxMaterialDarkSoft";
    font = {
      name = "meslo-lg";
      size = 20.0;
      package = pkgs.nerd-fonts.meslo-lg;
    };
    settings = {
      enabled_layouts = lib.strings.concatStringsSep "," [
        # "fat"
        "grid"
        # "horizontal"
        # "splits"
        "stack"
        "tall"
        # "vertical"
      ];
    };
    keybindings =
      {
        # clipboard

        "kitty_mod+c" = "copy_to_clipboard";
        "cmd+c" = "copy_to_clipboard";

        "kitty_mod+v" = "paste_from_clipboard";
        "cmd+v" = "paste_from_clipboard";

        "kitty_mod+s" = "";
        "shift+insert" = "";

        "kitty_mod+o" = "open_url_with_hints";
      }
      // {
        # scrolling

        "kitty_mod+up" = "scroll_line_up";
        "kitty_mod+k" = "scroll_line_up";
        "opt+cmd+page_up" = "scroll_line_up";
        "cmd+up" = "scroll_line_up";

        "kitty_mod+down" = "scroll_line_down";
        "kitty_mod+j" = "scroll_line_down";
        "opt+cmd+page_down" = "scroll_line_down";
        "cmd+down" = "scroll_line_down";

        "kitty_mod+page_up" = "scroll_page_up";
        "cmd+page_up" = "scroll_page_up";

        "kitty_mod+page_down" = "scroll_page_down";
        "cmd+page_down" = "scroll_page_down";

        "kitty_mod+home" = "scroll_home";
        "cmd+home" = "scroll_home";

        "kitty_mod+end" = "scroll_end";
        "cmd+end" = "scroll_end";

        # "kitty_mod+z" = "";
        # "kitty_mod+u" = "scroll_to_prompt -1";

        # "kitty_mod+x" = "";
        # "kitty_mod+d" = "scroll_to_prompt 1";

        # "kitty_mod+h" = ""; # was 'show scrollback'
        # "kitty_mod+g" = ""; # was 'show last command output'
      }
      // {
        # window management

        "kitty_mod+enter" = "new_window";
        "cmd+enter" = "new_window";

        "kitty_mod+n" = "new_os_window";
        "cmd+n" = "new_os_window";

        "kitty_mod+w" = "close_window";
        "shift+cmd+d" = "close_window";

        "kitty_mod+]" = "next_window";

        "kitty_mod+[" = "prev_window";

        "kitty_mod+f" = "";
        "kitty_mod+b" = "";
        "kitty_mod+`" = "";

        "kitty_mod+r" = ""; # was 'window resize'
        "cmd+r" = "";

        "kitty_mod+1" = "";
        "cmd+1" = "";

        "kitty_mod+2" = "";
        "cmd+2" = "";

        "kitty_mod+3" = "";
        "cmd+3" = "";

        "kitty_mod+4" = "";
        "cmd+4" = "";

        "kitty_mod+5" = "";
        "cmd+5" = "";

        "kitty_mod+6" = "";
        "cmd+6" = "";

        "kitty_mod+7" = "";
        "cmd+7" = "";

        "kitty_mod+8" = "";
        "cmd+8" = "";

        "kitty_mod+9" = "";
        "cmd+9" = "";

        "kitty_mod+0" = "";

        "kitty_mod+f7" = "";

        "kitty_mod+f8" = "";
      }
      // {
        # tab management

        "kitty_mod+right" = "next_tab";
        "shift+cmd+]" = "next_tab";
        "ctrl+tab" = "next_tab";

        "kitty_mod+left" = "previous_tab";
        "shift+cmd+[" = "previous_tab";
        "kitty_mod+tab" = "previous_tab";

        "kitty_mod+t" = "new_tab";
        "cmd+t" = "new_tab";

        "kitty_mod+q" = "";
        # "cmd+w" = "";
        "shift+cmd+w" = "close_os_window";

        "kitty_mod+." = "";
        "kitty_mod+," = "";
        "kitty_mod+alt+t" = "";
        "shift+cmd+i" = "";
      }
      // {
        # layout management

        "kitty_mod+l" = ""; # was 'next layout'
        "shift+alt+l" = "next_layout";

        "shift+alt+s" = "goto_layout stack";
        "shift+alt+t" = "goto_layout tall";
        "shift+alt+f" = "goto_layout fat";
        "shift+alt+g" = "goto_layout grid";
        "shift+alt+x" = "goto_layout splits";
        "shift+alt+v" = "goto_layout vertical";
        "shift+alt+h" = "goto_layout horizontal";
      }
      // {
        # font sizes

        "kitty_mod+equal" = "change_font_size all +2.0";
        "kitty_mod+plus" = "change_font_size all +2.0";
        "kitty_mod+kp_add" = "change_font_size all +2.0";
        "cmd+plus" = "change_font_size all +2.0";
        "cmd+equal" = "change_font_size all +2.0";
        "shift+cmd+equal" = "change_font_size all +2.0";

        "kitty_mod+minus" = "change_font_size all -2.0";
        "kitty_mod+kp_subtract" = "change_font_size all -2.0";
        "cmd+minus" = "change_font_size all -2.0";
        "shift+cmd+minus" = "change_font_size all -2.0";

        "kitty_mod+backspace" = "change_font_size all 0";
        "cmd+0" = "change_font_size all 0";
      }
      // {
        # visible text manipulation

        "kitty_mod+e" = ""; # was 'open link'
        "kitty_mod+p>f" = "kitten hints --type path --program -";
        "kitty_mod+p>shift+f" = "kitten hints --type path";
        "kitty_mod+p>l" = "kitten hints --type line --program -";
        "kitty_mod+p>w" = "kitten hints --type word --program -";
        "kitty_mod+p>h" = "kitten hints --type hash --program -";
        "kitty_mod+p>n" = "kitten hints --type linenum";
        "kitty_mod+p>y" = "kitten hints --type hyperlink";
      }
      // {
        # miscellaneous

        "kitty_mod+f1" = "";
        "kitty_mod+f11" = "";
        "ctrl+cmd+f" = "";
        "kitty_mod+f10" = "";
        "opt+cmd+s" = "";
        # "kitty_mod+u" = "";
        "ctrl+cmd+space" = "";
        "kitty_mod+f2" = "";
        "cmd+," = "";
        # "kitty_mod+escape" = "";
        "kitty_mod+a>m" = "";
        "kitty_mod+a>l" = "";
        "kitty_mod+a>1" = "";
        "kitty_mod+a>d" = "";
        # "kitty_mod+delete" = "";
        "opt+cmd+r" = "";
        # "cmd+k" = "";
        "option+cmd+k" = "";
        "cmd+ctrl+l" = "";
        "kitty_mod+f5" = "";
        "ctrl+cmd+," = "";
        "kitty_mod+f6" = "";
        "opt+cmd+," = "";
        "shift+cmd+/" = "";
        # "cmd+h" = "";
        "opt+cmd+h" = "";
        # "cmd+m" = "";
        # "cmd+q" = "";
      };
    environment = {};
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };
}

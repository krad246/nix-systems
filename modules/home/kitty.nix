{
  withSystem,
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
      package =
        withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts);
    };
    keybindings = {
      # clipboard
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+s" = "";
      "ctrl+shift+o" = "";

      # scrolling
      "ctrl+shift+k" = "scroll_line_up";
      "ctrl+shift+j" = "scroll_line_down";
      "ctrl+shift+page_up" = "scroll_page_up";
      "ctrl+shift+page_down" = "scroll_page_down";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end" = "scroll_end";
      "ctrl+shift+up" = "scroll_to_prompt -1"; # was 'scroll to previous prompt'
      "ctrl+shift+down" = "scroll_to_prompt 1"; # was 'scroll to next prompt'
      "ctrl+shift+h" = ""; # was 'show scrollback'
      "ctrl+shift+g" = ""; # was 'show last command output'
      "f1" = "";

      # window management
      "ctrl+shift+n" = "new_os_window";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+]" = "next_window";
      "alt+]" = "next_window";
      "ctrl+shift+[" = "prev_window";
      "alt+[" = "prev_window";
      "ctrl+shift+f" = "";
      "ctrl+shift+b" = "";
      "ctrl+shift+`" = "";
      "ctrl+shift+r" = ""; # was 'window resize'
      "ctrl+shift+1" = "";
      "ctrl+shift+2" = "";
      "ctrl+shift+3" = "";
      "ctrl+shift+4" = "";
      "ctrl+shift+5" = "";
      "ctrl+shift+6" = "";
      "ctrl+shift+7" = "";
      "ctrl+shift+8" = "";
      "ctrl+shift+9" = "";
      "ctrl+shift+0" = "";
      "ctrl+shift+f7" = "";
      "ctrl+shift+f8" = "";

      # tab management
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "";
      "ctrl+shift+." = "move_tab_forward";
      "ctrl+shift+," = "move_tab_backward";
      "ctrl+shift+alt+t" = "";

      # layout management
      "ctrl+shift+l" = ""; # was 'next layout'

      # visible text manipulation
      "ctrl+shift+e" = ""; # was 'open link'

      # miscellaneous
      "ctrl+shift+u" = "";
      "ctrl+shift+delete" = "";
      "ctrl+l" = "clear_terminal to_cursor_scroll active";
    };
    environment = {};
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };
}

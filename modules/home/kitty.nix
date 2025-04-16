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
      "ctrl+shift+e" = ""; # was 'open link'
      "ctrl+shift+r" = ""; # was 'window resize'

      "ctrl+shift+g" = ""; # was 'show last command output'
      "ctrl+shift+up" = "scroll_to_prompt -1"; # was 'scroll to previous prompt'
      "ctrl+shift+down" = "scroll_to_prompt 1"; # was 'scroll to next prompt'

      "ctrl+shift+l" = ""; # was 'next layout'
      "ctrl+l" = "clear_terminal to_cursor_scroll active";

      # a window is a tile in a 'tab', essentially
      "ctrl+shift+]" = ""; # was 'next_window'
      "alt+]" = "next_window";
      "ctrl+shift+[" = "";
      "alt+[" = "prev_window";
    };
    environment = {};
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };
}

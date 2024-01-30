{
  programs.kitty = {
    enable = true;
    shellIntegration.mode = "enabled";
    theme = "Gruvbox Material Dark Soft";
    font = {
      name = "meslo-lg";
      size = 14.0;
    };
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };
}

{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    shellIntegration.mode = "enabled";
    theme = "Gruvbox Material Dark Soft";
    font = {
      name = "meslo-lg";
      size = 20.0;
      package = pkgs.nerdfonts.override {
        fonts = [
          "Meslo"
        ];
      };
    };
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };
}

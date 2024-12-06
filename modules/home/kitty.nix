{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    darwinLaunchOptions = ["--single-instance"];
    shellIntegration = {
      mode = "enabled";
      enableBashIntegration = true;
    };
    theme = "Gruvbox Material Dark Soft";
    font = {
      name = "meslo-lg";
      size = 20.0;
      package = pkgs.nerdfonts.override {
        fonts = [
          "Meslo"
          "NerdFontsSymbolsOnly"
        ];
      };
    };
    keybindings = {};
    environment = {};
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };
}

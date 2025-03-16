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
    keybindings = {};
    environment = {};
    extraConfig = ''
      confirm_os_window_close 0
    '';
  };
}

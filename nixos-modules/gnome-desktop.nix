{pkgs, ...}: {
  services = {
    xserver = {
      enable = true;
      enableCtrlAltBackspace = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      displayManager.startx.enable = true;
      videoDrivers = ["modesetting"];
      excludePackages = with pkgs; [xterm];
    };
  };

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-text-editor
      gedit # text editor
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      gnome-calculator
      gnome-maps
      gnome-system-monitor
      epiphany # web browser
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp
    ]);

  environment.systemPackages = with pkgs; [gnomeExtensions.dash-to-panel];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.system76-scheduler.enable = true;
}

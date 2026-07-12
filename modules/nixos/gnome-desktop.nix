{pkgs, ...}: {
  services = {
    xserver = {
      enable = true;
      enableCtrlAltBackspace = true;
      excludePackages = with pkgs; [xterm];
    };

    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  environment.gnome.excludePackages =
    (with pkgs; [
      simple-scan
      gnome-photos
      gnome-tour
      gnome-text-editor
      gedit # text editor
    ])
    ++ (with pkgs; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      gnome-calculator
      gnome-maps
      gnome-system-monitor
      gnome-clocks
      gnome-weather
      gnome-contacts
      gnome-calendar
      geary
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
}

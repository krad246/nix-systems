{
  lib,
  pkgs,
  ...
}: {
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
      simple-scan
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
      gnome-clocks
      gnome-weather
      gnome-contacts
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

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = lib.mkIf pkgs.stdenv.isx86_64 true;
    };
  };

  environment.systemPackages = with pkgs; [
    whitesur-gtk-theme
    whitesur-icon-theme
    whitesur-cursors
  ];

  # Enable sound with pipewire.
  sound.enable = lib.mkDefault true;
  security.rtkit.enable = true;
  services = {
    system76-scheduler.enable = true;
    pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}

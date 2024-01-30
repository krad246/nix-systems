{pkgs, ...}: {
  # Drop some of the more... annoying of elementary's programs
  environment.pantheon.excludePackages = with pkgs.pantheon; [
    elementary-music
    elementary-tasks
    elementary-feedback
    elementary-calculator
    elementary-code
    elementary-videos
    elementary-terminal
  ];

  # Enable X11 windowing.
  # Select the Pantheon desktop environment (elementary OS)
  # Add extra indicators and panel plugins.
  # Enable high-resolution booting.
  # Enable wacom tablets.
  services = {
    pantheon = {
      apps.enable = true;
      contractor.enable = true;
    };

    xserver = {
      enable = true;
      enableCtrlAltBackspace = true;
      displayManager.lightdm.enable = true;
      desktopManager.pantheon.enable = true;
      displayManager.startx.enable = true;
      videoDrivers = ["modesetting"];
      excludePackages = with pkgs; [xterm];
    };
  };

  programs.pantheon-tweaks.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.system76-scheduler.enable = true;
}

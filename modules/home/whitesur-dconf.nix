{
  imports = [./dconf.nix];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "WhiteSur-cursors";
      gtk-theme = "WhiteSur-Dark";
      icon-theme = "WhiteSur-dark";
    };
  };
}

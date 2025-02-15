{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    whitesur-gtk-theme
    whitesur-icon-theme
    whitesur-cursors
  ];
}

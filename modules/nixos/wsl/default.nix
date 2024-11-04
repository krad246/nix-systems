{
  imports = [./docker-desktop.nix ./fstab.nix ./wsl.nix];

  nix.settings.sandbox = false;
}

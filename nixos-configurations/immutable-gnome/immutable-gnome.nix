_args: {
  imports =
    [
      ../../nixos-modules/cachix.nix
      ../../nixos-modules/docker.nix
      ../../nixos-modules/efiboot.nix
      ../../nixos-modules/flatpak.nix
      ../../nixos-modules/gnome-desktop.nix
      ../../nixos-modules/libvirtd.nix
      ../../nixos-modules/kdeconnect.nix
      ../../nixos-modules/nerdfonts.nix
      ../../nixos-modules/nixos
      ../../nixos-modules/nix-ld.nix
      ../../nixos-modules/pipewire.nix
      ../../nixos-modules/vscode-server.nix
    ]
    ++ [(import ./filesystems.nix {})];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi";
    extraGroups = ["NetworkManager" "wheel" "libvirtd"];
    initialHashedPassword = "";
  };

  nix.settings.trusted-users = ["krad246"];
}

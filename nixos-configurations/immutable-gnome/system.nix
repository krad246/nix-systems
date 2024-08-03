{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ [
      ../../nixos-modules/gnome-desktop.nix
      ../../nixos-modules/kdeconnect.nix
      ../../nixos-modules/nixos
      ../../nixos-modules/pam-u2f.nix
      ../../nixos-modules/pipewire.nix
      ../../nixos-modules/vscode-server.nix
    ];

  # Default settings are simple EFI system on tmpfs
  boot.loader.grub.device = lib.mkDefault "nodev";
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults"];
  };

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi";
    extraGroups = ["NetworkManager" "wheel" "libvirtd"];
    initialHashedPassword = "";
  };

  nix.settings = {
    allowed-users = ["krad246"];
    trusted-users = ["krad246"];
  };

  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.hostName = lib.mkForce "immutable-gnome";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.trivial.release;
}

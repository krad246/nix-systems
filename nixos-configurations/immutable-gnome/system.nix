{
  inputs,
  config,
  lib,
  ...
}: let
  disko = import ./fetch-disko.nix;
  inherit (inputs) nixos-generators;
in {
  imports =
    [disko]
    ++ [nixos-generators.nixosModules.all-formats]
    ++ [
      ../../nixos-modules/gnome-desktop.nix
      ../../nixos-modules/kdeconnect.nix
      ../../nixos-modules/nixos
      ../../nixos-modules/pam-u2f.nix
      ../../nixos-modules/pipewire.nix
      ../../nixos-modules/vscode-server.nix
    ]
    ++ [./formats/impermanence.nix];

  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults"];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  networking.hostName = lib.mkForce "immutable-gnome";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.trivial.release;
}

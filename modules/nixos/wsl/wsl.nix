{inputs, ...}: let
  inherit (inputs) nixos-wsl;
in {
  imports = [nixos-wsl.nixosModules.wsl];

  # It might as well be...
  # Disable nonsensical services for it...
  boot = {
    loader.grub.device = "nodev"; # or "nodev" for efi only
    isContainer = true;
  };

  systemd.services = {
    "serial-getty@ttyS0".enable = false;
    "serial-getty@hvc0".enable = false;
    "getty@tty1".enable = false;
    "autovt@".enable = false;
    firewall.enable = false;
    systemd-resolved.enable = false;
    systemd-udevd.enable = false;
  };

  # Doesn't make sense because we don't have a console.
  systemd.enableEmergencyMode = false;

  wsl = {
    enable = true;
    interop = {
      register = true;
      includePath = true;
    };
    usbip.autoAttach = [];
    useWindowsDriver = true;
    startMenuLaunchers = true;
    nativeSystemd = true;

    wslConf = {
      automount.enabled = true;
      boot.systemd = true;
      interop = {
        enabled = true;
        appendWindowsPath = true;
      };
    };
  };
}

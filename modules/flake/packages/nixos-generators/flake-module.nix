{
  withSystem,
  self,
  ...
}: let
  mkFormat = _pkgs: host: format:
    self.nixosConfigurations.${host}.config.formats.${format};
in {
  flake.packages.aarch64-linux = withSystem "aarch64-linux" ({pkgs, ...}: {
    fortress-sd-aarch64 = mkFormat pkgs "fortress" "sd-aarch64";
    fortress-sd-aarch64-installer = mkFormat pkgs "fortress" "sd-aarch64-installer";
  });

  flake.packages.x86_64-linux = withSystem "x86_64-linux" ({pkgs, ...}: {
    fortress-sd-x86_64 = mkFormat pkgs "fortress" "sd-x86_64";

    fortress-virtualbox = mkFormat pkgs "fortress" "virtualbox";
    fortress-vagrant-virtualbox = mkFormat pkgs "fortress" "vagrant-virtualbox";

    fortress-vmware = mkFormat pkgs "fortress" "vmware";
  });

  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    packages = lib.modules.mkIf pkgs.stdenv.isLinux {
      fortress-hyperv = mkFormat pkgs "fortress" "hyperv";
      fortress-iso = mkFormat pkgs "fortress" "iso";
      fortress-install-iso = mkFormat pkgs "fortress" "install-iso";
      fortress-install-iso-hyperv = mkFormat pkgs "fortress" "install-iso-hyperv";

      fortress-qcow = mkFormat pkgs "fortress" "qcow";
      fortress-qcow-efi = mkFormat pkgs "fortress" "qcow-efi";

      fortress-raw = mkFormat pkgs "fortress" "raw";
      fortress-raw-efi = mkFormat pkgs "fortress" "raw-efi";
    };
  };
}

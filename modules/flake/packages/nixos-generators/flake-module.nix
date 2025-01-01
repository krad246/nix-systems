{
  withSystem,
  self,
  ...
}: let
  mkFormat = pkgs: host: format: let
    inherit (pkgs) lib;
    inherit (lib) modules;
    e = self.nixosConfigurations.${host}.extendModules {
      modules = [
        {
          nixpkgs.system = pkgs.lib.modules.mkForce pkgs.stdenv.system;
          hardware = pkgs.lib.modules.mkIf pkgs.stdenv.isx86_64 rec {
            opengl.driSupport32Bit = modules.mkForce false;
            graphics.enable32Bit = opengl.driSupport32Bit;
          };
        }
      ];
    };
  in
    e.config.formats.${format};
in {
  flake.packages = {
    aarch64-darwin =
      withSystem "aarch64-darwin" (_: {
      });

    aarch64-linux = withSystem "aarch64-linux" ({pkgs, ...}: {
      fortress-sd-aarch64 = mkFormat pkgs "fortress" "sd-aarch64";
      fortress-sd-aarch64-installer = mkFormat pkgs "fortress" "sd-aarch64-installer";
    });

    x86_64-linux = withSystem "x86_64-linux" ({pkgs, ...}: {
      fortress-sd-x86_64 = mkFormat pkgs "fortress" "sd-x86_64";

      fortress-virtualbox = mkFormat pkgs "fortress" "virtualbox";
      fortress-vagrant-virtualbox = mkFormat pkgs "fortress" "vagrant-virtualbox";

      fortress-vmware = mkFormat pkgs "fortress" "vmware";
    });
  };

  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    packages = lib.modules.mkIf pkgs.stdenv.isLinux {
      fortress-disko-vm = mkFormat pkgs "fortress" "disko-vm";
      # disko-vm-darwin = mkFormat pkgs "fortress" "disko-vm-darwin";

      fortress-hyperv = mkFormat pkgs "fortress" "hyperv";
      fortress-iso = mkFormat pkgs "fortress" "iso";
      fortress-install-iso = mkFormat pkgs "fortress" "install-iso";
      fortress-install-iso-hyperv = mkFormat pkgs "fortress" "install-iso-hyperv";

      # fortress-qcow = mkFormat pkgs "fortress" "qcow";
      fortress-qcow-efi = mkFormat pkgs "fortress" "qcow-efi";

      fortress-raw = mkFormat pkgs "fortress" "raw";
      fortress-raw-efi = mkFormat pkgs "fortress" "raw-efi";

      fortress-vm = mkFormat pkgs "fortress" "vm";

      windex-tarball = mkFormat pkgs "windex" "tarball";
    };
  };
}

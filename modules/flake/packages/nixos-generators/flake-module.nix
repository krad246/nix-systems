{
  withSystem,
  inputs,
  self,
  specialArgs,
  ...
}: let
  mkFormat = pkgs: host: format:
    inputs.nixos-generators.nixosGenerate {
      inherit format;
      inherit (pkgs.stdenv) system;
      inherit specialArgs;
      modules = [
        {nixpkgs.system = pkgs.stdenv.system;}

        inputs.agenix.nixosModules.age
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        inputs.nixos-generators.nixosModules.all-formats

        self.nixosModules.${host}
        self.nixosConfigurations.${host}.config.formatConfigs.${format}
      ];
    };
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

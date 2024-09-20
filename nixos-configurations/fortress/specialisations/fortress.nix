{
  ezModules,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) nixos-hardware;
in {
  specialisation = {
    fortress = {
      configuration = {
        imports =
          [ezModules.flatpak ezModules.kdeconnect]
          ++ [
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixos-hardware.nixosModules.common-cpu-amd-zenpower
            nixos-hardware.nixosModules.common-gpu-amd
            nixos-hardware.nixosModules.common-hidpi
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.common-pc-ssd
          ];

        hardware.steam-hardware.enable = true;
        boot.kernelPackages = pkgs.linuxPackages_latest;
        services.switcherooControl.enable = true;
      };
    };
  };
}

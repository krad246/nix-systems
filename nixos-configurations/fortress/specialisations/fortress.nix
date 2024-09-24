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
          (with ezModules; [
            avahi
            bluetooth
            efiboot
            flatpak
            kdeconnect
            pipewire
            system76-scheduler
          ])
          ++ (with nixos-hardware.nixosModules; [
            common-cpu-amd
            common-cpu-amd-pstate
            common-cpu-amd-zenpower
            common-gpu-amd
            common-hidpi
            common-pc
            common-pc-ssd
          ]);

        boot.kernelPackages = pkgs.linuxPackages_latest;

        programs.ssh = {
          startAgent = true;
        };

        services = {
          openssh = {
            enable = true;
            startWhenNeeded = true;
            ports = [22];
            settings = {
            };
          };
        };

        boot.kernelParams = ["usbcore.old_scheme_first=1"];
      };
    };
  };
}

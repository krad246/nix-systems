{
  ezModules,
  inputs,
  config,
  lib,
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
          ++ lib.optionals pkgs.stdenv.isx86_64 (with nixos-hardware.nixosModules; [
            common-cpu-amd
            common-cpu-amd-pstate
            common-cpu-amd-zenpower
            common-gpu-amd
            common-hidpi
            common-pc
            common-pc-ssd
          ]);

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

        services.cachix-watch-store = lib.mkIf (lib.attrsets.hasAttrByPath ["cachix.age"]
          config.age.secrets) {
          enable = true;
          cacheName = "krad246";
          cachixTokenFile = config.age.secrets."cachix.age".path;
          verbose = true;
        };
      };
    };
  };
}

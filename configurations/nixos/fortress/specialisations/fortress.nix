{
  self,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) nixos-hardware;
in {
  specialisation = {
    fortress = {
      configuration = {
        config,
        lib,
        ...
      }: let
        inherit (lib) attrsets lists modules;

        hasPrivKey =
          attrsets.hasAttrByPath
          ["id_ed25519_priv.age"]
          config.age.secrets;
        hasPubKey =
          attrsets.hasAttrByPath
          ["id_ed25519_pub.age"]
          config.age.secrets;
      in {
        imports =
          (with self.nixosModules; [
            agenix
            avahi
            bluetooth
            efiboot
            flatpak
            kdeconnect
            pipewire
            rdp
            system76-scheduler
            wireshark
          ])
          ++ lists.optionals pkgs.stdenv.isx86_64 ([./hardware-configuration.nix]
            ++ (with nixos-hardware.nixosModules; [
              common-cpu-amd
              common-cpu-amd-pstate
              common-cpu-amd-zenpower
              common-gpu-amd
              common-hidpi
              common-pc
              common-pc-ssd
            ]));

        programs.ssh = modules.mkIf (hasPrivKey && hasPubKey) {
          startAgent = true;
        };

        services = modules.mkIf (hasPrivKey && hasPubKey) {
          openssh = {
            enable = true;
            startWhenNeeded = true;
            ports = [22];
            settings = {
            };
          };

          cachix-watch-store = modules.mkIf (attrsets.hasAttrByPath ["cachix.age"]
            config.age.secrets) {
            enable = true;
            cacheName = "krad246";
            cachixTokenFile = config.age.secrets."cachix.age".path;
            verbose = true;
          };
        };

        boot = {
          kernelParams = ["usbcore.old_scheme_first=1"];
        };

        virtualisation.docker.enable = true;
      };
    };
  };
}

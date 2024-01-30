{inputs, ...}: let
  inherit (inputs) impermanence;
in {
  imports = [impermanence.nixosModules.impermanence];

  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  fileSystems."/nix/persist".neededForBoot = true;

  users.mutableUsers = false;
}

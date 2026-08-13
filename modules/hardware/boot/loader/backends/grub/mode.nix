{lib, ...}: {
  flake.modules.nixos.grub = {config, ...}: let
    cfg = config.boot.loader.backends.grub;
  in {
    options.boot.loader.backends.grub.mode = lib.options.mkOption {
      type = lib.types.enum [
        "bios"
        "efi"
      ];
    };

    config = lib.modules.mkIf cfg.enable {
      boot.loader.grub = lib.modules.mkIf (cfg.mode == "efi") {
        device = "nodev";
        efiSupport = true;

        # TODO: use this only in deployments with disko.
        # efiInstallAsRemovable = lib.modules.mkDefault false;
      };
    };
  };
}

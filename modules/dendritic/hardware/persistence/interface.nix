{lib, ...}: {
  flake.modules.nixos.persistence = {config, ...}: {
    options.persistence = {
      enable = lib.options.mkEnableOption "persistent system state";

      path = lib.options.mkOption {
        type = lib.types.str;
        default = "/nix/persist";
        description = "Filesystem path used for persistent system state.";
      };

      neededForBoot = lib.options.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the persistence filesystem is needed during boot.";
      };

      hideMounts = lib.options.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether persistence mounts are hidden from regular mount listings.";
      };

      directories = lib.options.mkOption {
        type = lib.types.listOf lib.types.raw;
        default = [];
        description = "Directories retained by the selected persistence backend.";
      };

      files = lib.options.mkOption {
        type = lib.types.listOf lib.types.raw;
        default = [];
        description = "Files retained by the selected persistence backend.";
      };
    };

    config = lib.mkIf config.persistence.enable {
      fileSystems.${config.persistence.path}.neededForBoot =
        lib.mkDefault config.persistence.neededForBoot;
    };
  };
}

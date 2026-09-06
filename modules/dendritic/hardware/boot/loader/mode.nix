{lib, ...}: {
  flake.modules.nixos.bootloader = {config, ...}: let
    cfg = config.boot.loader;
  in {
    options.boot.loader.mode = lib.options.mkOption {
      type = lib.types.enum ["bios" "efi"];
    };

    config = lib.modules.mkIf (cfg.mode == "efi") {
      boot.loader.efi.canTouchEfiVariables = lib.modules.mkDefault true;
    };
  };
}

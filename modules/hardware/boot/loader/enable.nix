{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.bootloader = {config, ...}: let
    cfg = config.boot.loader;
  in {
    imports = with self.modules.nixos; [
      grub
      systemd-boot
    ];

    options.boot.loader.enable = lib.options.mkOption {
      type = lib.types.bool;
      default = true;
    };

    config = lib.modules.mkIf cfg.enable (
      lib.modules.mkMerge [
        {
          boot.loader.backends = {
            grub.enable = lib.modules.mkDefault true;
            systemd-boot.enable = lib.modules.mkDefault false;
          };
        }

        (lib.modules.mkIf cfg.backends.grub.enable {
          boot.loader.backends.grub.mode = cfg.mode;
        })
      ]
    );
  };
}

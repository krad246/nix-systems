{
  inputs,
  self,
  lib,
  ...
}: {
  flake.modules.nixos.impermanence = {config, ...}: {
    imports = [
      self.modules.nixos.persistence
      inputs.impermanence.nixosModules.impermanence
    ];

    options.persistence.backends.impermanence = {
      enable = lib.options.mkOption {
        type = lib.types.bool;
        default = config.persistence.enable;
        description = "Enable the impermanence persistence backend.";
      };
    };

    config = lib.mkIf config.persistence.backends.impermanence.enable {
      environment.persistence.${config.persistence.path} = {
        inherit (config.persistence) directories files hideMounts;
      };
    };
  };
}

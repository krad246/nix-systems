{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.secrets = {
      imports = [self.modules.homeManager.rbw];

      identity.secrets.backends.rbw.enable = lib.modules.mkDefault true;
    };

    darwin.secrets = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.secrets
      ];
    };

    nixos.secrets = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.secrets
      ];
    };
  };
}

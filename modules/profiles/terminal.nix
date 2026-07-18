{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.terminal = {
      imports = [self.modules.homeManager.kitty];

      terminal.backends.kitty.enable = lib.modules.mkDefault true;
    };

    nixos.terminal = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.terminal
      ];
    };

    darwin.terminal = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.terminal
      ];
    };
  };
}

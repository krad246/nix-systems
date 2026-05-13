{self, ...}: {
  flake.modules = {
    homeManager.desktop = {
      imports = [self.modules.homeManager.terminal];
    };

    nixos.desktop = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.desktop
      ];
    };

    darwin.desktop = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.desktop
      ];
    };
  };
}

{self, ...}: {
  flake.modules = {
    homeManager.desktop = {
      imports = with self.modules.homeManager; [
        browser
        terminal
      ];
    };

    nixos.desktop = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.desktop
      ];
    };

    darwin.desktop = {config, ...}: {
      imports = with self.modules.darwin; [
        app-stores
        browser
      ];

      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.desktop
      ];
    };
  };
}

{self, ...}: {
  flake.modules = {
    homeManager.dev = {
      imports = [self.modules.homeManager.base];

      shell.profiles.dev.enable = true;
    };

    nixos.dev = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.dev
      ];
    };

    darwin.dev = {config, ...}: {
      home-manager.users.${config.owner.username}.imports = [
        self.modules.homeManager.dev
      ];
    };
  };
}

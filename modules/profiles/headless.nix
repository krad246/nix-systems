{self, ...}: {
  flake.modules.nixos.headless = {config, ...}: {
    imports = with self.modules.nixos; [
      base
    ];

    environment.enableAllTerminfo = true;

    home-manager.users.${config.owner.username}.imports = [
      self.modules.homeManager.base
    ];
  };
}

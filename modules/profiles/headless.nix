{self, ...}: {
  flake.modules.nixos.headless = {config, ...}: {
    imports = with self.modules.nixos; [
      minimal
    ];

    environment.enableAllTerminfo = true;

    home-manager.users.${config.owner.username}.imports = [
      self.modules.homeManager.minimal
    ];
  };
}

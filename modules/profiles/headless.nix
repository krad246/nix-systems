{self, ...}: {
  flake.modules = {
    homeManager.headless = {
      imports = [self.modules.homeManager.base];
    };

    nixos.headless = {
      imports = with self.modules.nixos; [
        base
        terminfo
      ];
    };
  };
}

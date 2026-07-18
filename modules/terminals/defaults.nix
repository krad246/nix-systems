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

    nixos.terminal = {
      imports = [self.modules.nixos.kmscon];

      terminal.backends.kmscon.enable = lib.modules.mkDefault true;
    };
  };
}

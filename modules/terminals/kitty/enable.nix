{self, ...}: {
  flake.modules.homeManager.kitty = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.nixpkgs-unstable];

    programs.kitty = {
      enable = lib.modules.mkDefault config.terminal.backends.kitty.enable;
      package = pkgs.unstable.kitty;
    };
  };
}

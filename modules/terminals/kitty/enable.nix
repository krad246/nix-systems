{self, ...}: {
  flake.modules.homeManager.kitty = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.nixpkgs-unstable];

    options.terminal.backends.kitty.enable =
      lib.options.mkEnableOption "Kitty as an active terminal backend";

    config.programs.kitty = {
      enable = lib.modules.mkDefault config.terminal.backends.kitty.enable;
      package = pkgs.unstable.kitty;
    };
  };
}

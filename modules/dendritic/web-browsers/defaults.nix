{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.browser = {
    imports = [self.modules.homeManager.zen-browser];
  };

  flake.modules.darwin.browser = {config, ...}: {
    imports = [self.modules.darwin.zen-browser];

    browser.backends.zen.enable = lib.modules.mkDefault true;

    home-manager.users.${config.owner.username}.browser.backends.zen = {
      enable = lib.modules.mkDefault config.browser.backends.zen.enable;
      default = lib.modules.mkDefault config.browser.backends.zen.enable;
    };
  };
}

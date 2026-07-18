{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.browser = {
    imports = [self.modules.homeManager.zen-browser];

    browser.backends.zen = {
      enable = lib.modules.mkDefault true;
      default = lib.modules.mkDefault true;
    };
  };

  flake.modules.darwin.browser = {
    imports = [self.modules.darwin.zen-browser];

    browser.backends.zen.enable = lib.modules.mkDefault true;
  };
}

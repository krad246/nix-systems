{config, ...}: let
  flakeConfig = config;
in {
  perSystem = {
    config,
    system,
    ...
  }: let
    darwin = flakeConfig.flake.darwinConfigurations;
    image = config.packages.generic-headless-interactive-vm-nogui-x86_64-linux or null;
  in {
    dendritic.assertions = [
      {
        assertion = system != "aarch64-darwin" || darwin ? nixbook-pro-composed;
        message = "the composed nixbook-pro Darwin configuration is published";
      }
      {
        assertion = system != "aarch64-darwin" || darwin.nixbook-pro-composed.config.home-manager.users.krad246.shell.profiles.interactive.enable;
        message = "nixbook-pro includes the interactive user profile";
      }
      {
        assertion = system != "aarch64-darwin" || darwin.nixbook-pro-composed.config.home-manager.users.krad246.shell.profiles.dev.enable;
        message = "nixbook-pro includes the development user profile";
      }
      {
        assertion = system != "aarch64-darwin" || darwin.nixbook-pro-composed.config.home-manager.users.krad246.browser.backends.zen.enable;
        message = "nixbook-pro selects the Zen browser backend";
      }
      {
        assertion = system != "x86_64-linux" || image.name == "nixos-vm";
        message = "the generic headless image materializes as a NixOS VM";
      }
    ];
  };
}

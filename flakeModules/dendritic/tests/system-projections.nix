let
  flake = builtins.getFlake (toString ../../..);
  darwin = flake.darwinConfigurations;
  image = flake.packages.x86_64-linux.generic-headless-interactive-vm-nogui-x86_64-linux;
in
  # FIXME(dendritic-hosts): Restore deployable NixOS root assertions once host
  # declarations distinguish roots from image-only composition substrates.
  assert darwin ? nixbook-pro-composed;
  assert darwin.nixbook-pro-composed.config.home-manager.users.krad246.shell.profiles.interactive.enable;
  assert darwin.nixbook-pro-composed.config.home-manager.users.krad246.shell.profiles.dev.enable;
  assert darwin.nixbook-pro-composed.config.home-manager.users.krad246.browser.backends.zen.enable;
  assert image.name == "nixos-vm"; true

let
  flake = builtins.getFlake (toString ../../..);
  linux = flake.nixosConfigurations;
  darwin = flake.darwinConfigurations;
  artifact = flake.packages.x86_64-linux.generic-headless-interactive-vm-nogui-x86_64-linux;
in
  assert linux ? generic-headless-interactive;
  assert linux ? generic-headless-interactive-dev;
  assert linux ? generic-headless-interactive-vm-nogui;
  assert linux.generic-headless-interactive.config.specialisation ? vm-nogui;
  assert linux.generic-headless-interactive-dev.config.environment.etc.dendritic-variant.text == "dev";
  assert darwin ? nixbook-pro-composed;
  assert darwin.nixbook-pro-composed.config.home-manager.users.krad246.home.sessionVariables.DENDRITIC_SYSTEM_USER == "true";
  assert artifact.name == "nixos-vm"; true

{
  inputs,
  self,
  config,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ (with self.nixosModules; [
      base-configuration
      wsl
    ]);

  programs.dconf.enable = false;

  # Doesn't make sense on WSL's network stack
  systemd.services.NetworkManager-wait-online.enable = false;

  # for direnv watching
  services.lorri.enable = true;

  # disable all formats other than the tarball format
  formats = lib.modules.mkForce {
    tarball = config.system.build.tarballBuilder;
  };

  formatConfigs = {
    tarball = {
      formatAttr = "tarballBuilder";
    };
  };

  # NixOS is going to get the first user ID
  # It'll own this distro as the default user
  wsl.defaultUser = "keerad";

  # Shared home with Windows; handled via overlayFS mount
  users.users.keerad = {
    uid = lib.modules.mkForce 1001;
    isNormalUser = true;
    home = "/home/keerad";
    description = "Keerthi Radhakrishnan";
    initialHashedPassword = "";
    extraGroups = ["wheel" "NetworkManager" "docker"];
  };

  # Linux user
  users.users.krad246 = {
    uid = 1002;
    isNormalUser = true;
    home = "/home/krad246";
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel" "NetworkManager" "docker"];
  };
}

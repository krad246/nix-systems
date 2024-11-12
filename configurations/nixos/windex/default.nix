{
  self,
  inputs,
  config,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ (with self.nixosModules; [
      nixos
      wsl
    ]);

  # NixOS is going to get the first user ID
  # It'll own this distro as the default user
  wsl.defaultUser = "keerad";

  # Shared home with Windows; handled via overlayFS mount
  users.users.keerad = {
    uid = lib.mkForce 1001;
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  formats = lib.mkForce {
    tarball = config.system.build.tarballBuilder;
  };

  formatConfigs = {
    tarball = {
      formatAttr = "tarballBuilder";
    };
  };

  # Doesn't make sense on WSL's network stack
  systemd.services.NetworkManager-wait-online.enable = false;
}

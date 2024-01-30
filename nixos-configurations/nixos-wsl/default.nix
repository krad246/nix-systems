{
  inputs,
  ezModules,
  lib,
  ...
}: {
  imports = with ezModules;
    [
      nixos
      wsl
      wsl-docker-desktop
      flake-registry
      cachix
      nix-ld
      inputs.vscode-server.nixosModules.default
    ]
    ++ [./platform.nix];

  networking.hostName = "nixos-wsl";

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
    initialHashedPassword = "";
    extraGroups = ["wheel" "NetworkManager" "docker"];
  };

  nix.settings.trusted-users = ["keerad" "krad246"];
}

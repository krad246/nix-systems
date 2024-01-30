{lib, ...}: {
  networking.hostName = lib.mkForce "nixos-wsl";

  # NixOS is going to get the first user ID
  # It'll own this distro as the default user

  # Shared home with Windows; handled via overlayFS mount
  users.users.keerad = {
    uid = lib.mkForce 1001;
    isNormalUser = true;
    home = "/home/keerad";
    description = "Keerthi Radhakrishnan";
    initialHashedPassword = "";
    extraGroups = ["wheel"];
  };

  # Linux user
  users.users.krad246 = {
    uid = 1002;
    isNormalUser = true;
    home = "/home/krad246";
    description = "Keerthi Radhakrishnan";
    initialHashedPassword = "";
    extraGroups = ["wheel"];
  };

  fileSystems."/c" = {
    depends = [
      "/mnt/c"
    ];

    device = "/mnt/c";
    fsType = "none";
    options = [
      "bind"
      "X-mount.mkdir"
    ];
  };

  wsl.defaultUser = "keerad";
}

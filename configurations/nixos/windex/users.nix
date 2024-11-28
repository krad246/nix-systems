{lib, ...}: {
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

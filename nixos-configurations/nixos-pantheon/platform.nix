{
  imports = [./filesystems.nix ./services.nix];

  # Linux user
  users.users.krad246 = {
    isNormalUser = true;
    home = "/home/krad246";
    description = "Keerthi Radhakrishnan";
    initialHashedPassword = "";
    extraGroups = ["wheel"];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}

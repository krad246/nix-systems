{
  # Keep the stock users laying around.
  users = {
    users.nixos = {
      initialHashedPassword = "";
      isNormalUser = true;
    };

    users.root = {
      initialHashedPassword = "";
      isSystemUser = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings = rec {
    allowed-users = ["nixos" "root" "@wheel"];
    trusted-users = ["nixos" "root" "@wheel"];
  };
}

{
  # Keep the stock users laying around.
  users = {
    users.nixos = {
      isNormalUser = true;
    };

    users.root = {
      isSystemUser = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings = rec {
    allowed-users = ["nixos" "root" "@wheel"];
    trusted-users = allowed-users;
  };
}

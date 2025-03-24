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

  security.sudo.wheelNeedsPassword = true;
}

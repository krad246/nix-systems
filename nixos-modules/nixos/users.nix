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
}

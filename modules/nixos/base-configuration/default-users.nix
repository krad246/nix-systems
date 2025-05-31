{lib, ...}: {
  # Keep the stock users laying around.
  users = {
    users.nixos = {
      isNormalUser = true;
    };

    users.root = {
      isSystemUser = true;
    };
  };

  security.sudo.wheelNeedsPassword = lib.modules.mkDefault true;

  # members of the wheel / admin group are able to execute privileged operations on the daemon.
  # trusted users are able to specify arbitrary binary substitutes, etc. as well as signing custom outputs.
  # otherwise, these outputs are not usable, and the daemon refuses to execute most 'advanced' operations.
  nix.settings.trusted-users = ["@wheel"];
}

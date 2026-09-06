{
  flake.modules = {
    darwin.tailscale = {
      services.tailscale.enable = true;
    };

    nixos.tailscale = {
      services.tailscale = {
        enable = true;
        # TODO: authKeyFile, authKeyParameters
        extraUpFlags = ["--ssh"];
      };
    };
  };
}

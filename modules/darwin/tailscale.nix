{pkgs, ...}: {
  services.tailscale = {
    enable = true;
    package = pkgs.tailscale.overrideAttrs {
      doCheck = false;
    };
  };
}

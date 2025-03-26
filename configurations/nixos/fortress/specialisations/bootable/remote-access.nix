{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    openssh = {
      enable = true;
      startWhenNeeded = true;
      ports = [22];
      settings = {
      };
    };

    tailscale = {
      enable = true;
      extraUpFlags = ["--ssh"];
    };
  };
}

{
  # essentially, systemd-nspawn containers are plugged into the 'externalInterface'
  # through virtual ethernet cables, the 'internalInterfaces', and container networks are
  # behind a NAT. this way they can run their own distinct networking configurations.
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "eth0";
    enableIPv6 = true;
  };
}

{
  boot = {
    loader = {
      grub.device = "nodev";
      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "max";
      };
    };
  };
}

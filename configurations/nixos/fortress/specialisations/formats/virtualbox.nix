_: {
  disabledModules = [../efiboot.nix];
  virtualbox = {
    extraDisk = {
      mountPoint = "/growable";
      size = 32 * 1024;
    };
  };
}

{lib, ...}: {
  virtualbox = {
    extraDisk = {
      mountPoint = "/growable";
      size = 32 * 1024;
    };
  };

  disko.enableConfig = lib.modules.mkForce false;
}

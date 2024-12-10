_: {
  disko.enableConfig = false;
  virtualisation.diskSize = 64 * 1024;

  virtualbox = {
    baseImageSize = 64 * 1024;
    memorySize = 6 * 1024;
    extraDisk = {
      mountPoint = "/growable";
      size = 32 * 1024;
    };
  };
}

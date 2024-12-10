{config, ...}: {
  disko.enableConfig = false;
  virtualisation.diskSize = 32 * 1024;

  virtualbox = {
    baseImageSize = config.virtualisation.diskSize;
    memorySize = 6 * 1024;
    extraDisk = {
      mountPoint = "/growable";
      size = 32 * 1024;
    };
  };
}

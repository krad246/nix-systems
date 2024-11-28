{
  disko.enableConfig = false;

  virtualbox = {
    baseImageSize = 64 * 1024;
    baseImageFreeSpace = 32 * 1024;
    memorySize = 6 * 1024;
    extraDisk = {
      mountPoint = "/growable";
      size = 32 * 1024;
    };
  };
}

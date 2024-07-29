{
  services.zram-generator.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}

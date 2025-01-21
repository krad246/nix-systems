{config, ...}: {
  services.cachix-watch-store = {
    enable = true;
    cacheName = "krad246";
    cachixTokenFile = config.age.secrets.cachix.path;
    verbose = true;
  };
}

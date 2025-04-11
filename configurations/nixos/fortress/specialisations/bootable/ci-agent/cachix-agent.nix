{config, ...}: {
  services.cachix-watch-store = {
    enable = true;
    cacheName = "krad246";
    cachixTokenFile = config.age.secrets.cachix-token.path;
    verbose = true;
  };
  age.secrets = {
    cachix-token = {
      file = ./secrets/cachix.age;
    };
  };
}

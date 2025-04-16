{config, ...}: {
  age.secrets = {
    "tailscale-auth.key" = {
      file = ./secrets/tailscale-auth-key.age;
      name = "tailscale-auth.key";
    };
  };

  services.tailscale.authKeyFile = config.age.secrets."tailscale-auth.key".path;
}

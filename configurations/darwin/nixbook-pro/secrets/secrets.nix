let
  nixbook-pro = {
    krad246 = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnXYLXHf5YatmbglLujnTScz1xe7rjPRWXRpGydx4Hb condor-janitor0e@icloud.com";
    };

    system = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiMqE0sNF1dbKR1M4N2vca4pv0k2Tp3l04Y3LHO6PHu root@nixbook-pro";
    };
  };

  inherit (nixbook-pro) krad246 system;
in {
  "id_ed25519_priv.age".publicKeys = [krad246.ed25519 system.ed25519];
}

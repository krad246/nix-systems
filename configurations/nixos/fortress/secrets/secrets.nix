let
  fortress = {
    krad246 = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDiqFKi5MJ8/wfHTV0RNE0pbtMm42TjTC/OzSRMwFaA6YCb3hddVlDuy2mbtlvuSfjjhhuMDwDnLkILRqXIaFHOk/4NtgiQtPnudhtGKr01Hr4Jg1+9bdYsKp9e+xUg5K/OBJXezUqeo/mpymCI1mZMxTtsbxFjue8/IdwFC5AFYN3SYrbzaPtOTTeekhy1fOUtTTLERNak6DOzEwqZc4esH0zbdAwVOy3tg1SYz8rHzsuYBlHHw9ygIC+K3hAp+n6NTZ+nsshBuGV3jt6PP6ahe2Vx9ce3gErVonS94y8uNCHaupRdjYwg4tbShVTLFJAMVBtQe8aZXbSAg2MlIgE7x8oRV+Gxh++TZVyi3ka52ncvhHi3DBquscMrzJV3HUmcewbJuvSsLd4V4w1iFdkChnPX9eglylF+b/PjJ12DvXZNm7u2LMMW/WhV855d2o8/XrcrlBWyuqGmEOXpln4zovkmYKwliJJMkzAVLy3urEz2B25BaAMIfZuqwrmWARU= krad246@fortress";
    };

    system = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg9s+XAwWrvRf0k16ua9/3tpxbohrTGJEp4rOPnqgOh root@fortress";
    };
  };

  inherit (fortress) krad246 system;
in {
  "id_ed25519_priv.age".publicKeys = [krad246.rsa system.ed25519];
  "cachix.age".publicKeys = [krad246.rsa system.ed25519];
}

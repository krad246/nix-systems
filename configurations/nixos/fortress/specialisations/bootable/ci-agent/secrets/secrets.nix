let
  fortress = {
    krad246 = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDiqFKi5MJ8/wfHTV0RNE0pbtMm42TjTC/OzSRMwFaA6YCb3hddVlDuy2mbtlvuSfjjhhuMDwDnLkILRqXIaFHOk/4NtgiQtPnudhtGKr01Hr4Jg1+9bdYsKp9e+xUg5K/OBJXezUqeo/mpymCI1mZMxTtsbxFjue8/IdwFC5AFYN3SYrbzaPtOTTeekhy1fOUtTTLERNak6DOzEwqZc4esH0zbdAwVOy3tg1SYz8rHzsuYBlHHw9ygIC+K3hAp+n6NTZ+nsshBuGV3jt6PP6ahe2Vx9ce3gErVonS94y8uNCHaupRdjYwg4tbShVTLFJAMVBtQe8aZXbSAg2MlIgE7x8oRV+Gxh++TZVyi3ka52ncvhHi3DBquscMrzJV3HUmcewbJuvSsLd4V4w1iFdkChnPX9eglylF+b/PjJ12DvXZNm7u2LMMW/WhV855d2o8/XrcrlBWyuqGmEOXpln4zovkmYKwliJJMkzAVLy3urEz2B25BaAMIfZuqwrmWARU= krad246@fortress";
    };

    root = {
      rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGM11qZR2ogXUbq8VxkGUwT22VhdbQtUwis3Xqsdaxg39AXLWKnA6HiLEtts8T4OMTa5r09GNGa45E7eqifoMSwLHY7JoCvPfyN6M61NX/NBs5tGIwzkoe8Pp3tyefwu8n4aP/zzlNe/slp9O9a5o6zid1yoreYtR1TAZ8xVwPT+UoxJzoTvFbOcOLzwtY0dIQbkGX4I03HzsBT6n8O/ywjXP5F/Y/QDc2ELjyu+KcGFJRy3lwRFYsXmb9bR18rGRcBa4kBrsr6UAzNiqmw3nVPBot5TQHbB9EZAM+heXqNU1FX/BAd1sciH6trlJGn05arutwwLBN2plnsXMTzOCJFC+Oq1ZkHRp7qQrn0jabMUq76zN8hR/mpU9jzkQdF8us2ZXvu2zBKjaE/LyQmr+rqAYm1RlOQy+BtVkVf2g8462enjKz5nPghIdFW9iMZLbkJBmWE09d6u16n+pVplQ6mBzZ5O8JJ3R764rjpNwRUl0bDss7liawH2msSFeYBe7bVuw9WWZVlw+c4pNSCOtn4MGUneVI02oNM1AFFNsHdBqkWFQ44AMZB9gZI8Y8M3YkmhsAtrP1ZK0yFkUeZtNSImom2LvGe7KmngzzSkF6maDuO+HasIgDekbQsInHOM5V1tQqoPQuaX+llhRdXMOgZyFfq6sJUGPMJo7PRxwNbw== root@fortress";
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg9s+XAwWrvRf0k16ua9/3tpxbohrTGJEp4rOPnqgOh root@fortress";
    };
  };
  inherit (fortress) krad246 root;
in {
  "./binary-caches.age".publicKeys = [krad246.rsa root.rsa root.ed25519];
  "./cachix.age".publicKeys = [krad246.rsa root.rsa root.ed25519];
  "./cluster-join-token.age".publicKeys = [krad246.rsa root.rsa root.ed25519];
  "./id_ed25519_priv.age".publicKeys = [krad246.rsa root.rsa root.ed25519];
}

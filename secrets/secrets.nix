let
  globals = {
    nixbook-air = {
      enable = true;
      secrets = [
        "cachix"
        "gh"
        "id_ed25519_priv"
        "id_ed25519_pub"
      ];

      keys = [
        # krad246@nixbook-air
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"

        # krad246@nixbook-air
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrJQiFW64lLJ2+90wQDNHtJhj2W++Z6h5RHuDuyCC9Tw4jqscin5tnJNy0TGSls3KpWaRsavOqRmW+zBSHXTEzUYp6TXIMvSVNS+K8hDmLeBNvxK41BbJjJ+uWSjufq4TrIpNwZIQo3uYCRQM3CgU65Mr4NlpjJ6rdAOBw9g0raYlIgNgdhs/ODE7TEsgQs+8Lsqy24BgGvxnEA1Pfkj1ZFacFsgz8TtMvvp7exgO+yyAeE1ZHN2eq3ISJVeBOSm6xzKm0s/S7Z86/QggJu58UOw7lxxKoYU2ToVd1Yp8gie9Ka9ptlRT/3VKUUiNVVKfc+uyHvMkN65iv6qFOYTd6LELGMdVZmc+9/RCmO41d5kxsNH/ce/eSGmRS0KIDtjaHD4PXNDINJjVTrx73psAz5nqe8XbUhTRsz9ht8MsAhx/jD+FN1hTKuzzXAIQw0LK1IS+GxymF6axgmZ00Tax8arrIc2sllhhD/HEhHLbYZg+23FMAM89PVUT55Bd0Pi5kU1dNNSzeclo2epe1cmrAdB7kqYrG6laFmQSlTlmxKrST9xhRgHrPECWFNhbEm2oImbh69mkD+HZ+70c4MDEmNuobR7jtNcylAJlcsQ+S6UQT1KKWIYPGnqjnBM2n6HNgHNofjbcAaVIQalv4+4urSUb8ebtQpGM/qUsjLiVQlQ== krad246@gmail.com"

        # root@nixbook-air
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7/zqo4VsyDk/760jQaV6GLJ40E4+ETMJPexWmsQOPc root@nixbook-air"
      ];
    };

    dullahan = {
      enable = true;
      secrets = [
        "cachix"
        "gh"
        "id_ed25519_priv"
        "id_ed25519_pub"
      ];

      keys = [
        # krad246@nixbook-air
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"

        # krad246@dullahan.local
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPdaQB2UtP+0510pyUtURep/MJSumxCBz8N5LD2WobMy9318c5Qmi0NONwXClaxsR8OElBMlRLZBc0DeWHr5RqhggQFqKUdud1+x+e23wPSSbwREMS1cucMRT1bBIpVU4LFoCGFHaxotsPNpigN3ABbsiYA7dNbWs3nIf+zMrJw4+V4HCFlV5sVNm4Bdau7BWyHKKxP7/F/GHUR7OH1Ue5y3N5oAgBb9g6Rl+J7vaiLTcYqBhm/9X+94TbsdVEkSWdwyRwu8hiBGg95Nh8Pl67fzecNwzPfH24k1/vn99rVgMkEa3nXSiChgwH49Z0RTSARQ2cCm27NhhF4QIpOpENDbIolXrSlGQM9JbDbQhI4HbiLAMDkjEsLsNAUP4uvVypYZMJSnYqQpYVdrASbhV043v51CxwhgUSBZvINlEvziHQTaTZo0ndWvvcrvni2LqMYnsqM8kzRbe4LqdBJZt325oN4MidGsZS3NGB+VgYTdAiNckOUPD4LvfLlVZ6Nfw3zk9U58jcHwyMvMkmfMmGwNphFYQQ1/XFMVI1g8l8khOdzuQDUhlUC/4rGObT4H8j3BOsGjaTo5C8MyFDG1UoINsMOszKwEKcUe8rGCK80DbiEb7lJ0ZY971TmIEX6xjlxZxBoxfQs9la4BJ3sffRspXZ3i/88SqpnKyHZj+bwQ== krad246@gmail.com"

        # root@dullahan.local
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXafRdLT+qPTMUzzMc35PxOP4zun6zIPTf98jQ6Bv5P"
      ];
    };

    fortress = {
      enable = true;
      secrets = [
        "id_ed25519_priv"
        "id_ed25519_pub"
      ];

      keys = [
        # krad246@fortress
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILP2iDHtDzybLv/qFHMiSeJ53Xjm5ehl4/SQDV2Lol1/"

        # krad246@fortress
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDiqFKi5MJ8/wfHTV0RNE0pbtMm42TjTC/OzSRMwFaA6YCb3hddVlDuy2mbtlvuSfjjhhuMDwDnLkILRqXIaFHOk/4NtgiQtPnudhtGKr01Hr4Jg1+9bdYsKp9e+xUg5K/OBJXezUqeo/mpymCI1mZMxTtsbxFjue8/IdwFC5AFYN3SYrbzaPtOTTeekhy1fOUtTTLERNak6DOzEwqZc4esH0zbdAwVOy3tg1SYz8rHzsuYBlHHw9ygIC+K3hAp+n6NTZ+nsshBuGV3jt6PP6ahe2Vx9ce3gErVonS94y8uNCHaupRdjYwg4tbShVTLFJAMVBtQe8aZXbSAg2MlIgE7x8oRV+Gxh++TZVyi3ka52ncvhHi3DBquscMrzJV3HUmcewbJuvSsLd4V4w1iFdkChnPX9eglylF+b/PjJ12DvXZNm7u2LMMW/WhV855d2o8/XrcrlBWyuqGmEOXpln4zovkmYKwliJJMkzAVLy3urEz2B25BaAMIfZuqwrmWARU= krad246@fortress"

        # root@fortress
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIUhwC51OWBAk+qY6ZOCc8L+C3pHLNKn3H4Z16aGOT5m root@fortress"
      ];
    };
  };

  mergeAttrsList = list: let
    # `binaryMerge start end` merges the elements at indices `index` of `list` such that `start <= index < end`
    # Type: Int -> Int -> Attrs
    binaryMerge = start: end:
    # assert start < end; # Invariant
      if end - start >= 2
      then
        # If there's at least 2 elements, split the range in two, recurse on each part and merge the result
        # The invariant is satisfied because each half will have at least 1 element
        binaryMerge start (start + (end - start) / 2)
        // binaryMerge (start + (end - start) / 2) end
      else
        # Otherwise there will be exactly 1 element due to the invariant, in which case we just return it directly
        builtins.elemAt list start;
  in
    if list == []
    then
      # Calling binaryMerge as below would not satisfy its invariant
      {}
    else binaryMerge 0 (builtins.length list);

  forEach = xs: f: builtins.map f xs;
  makeSecrets = hostname: keys: let
    mapKeys = fs:
      forEach fs (filename: {
        "./hosts/${hostname}/${filename}.age".publicKeys = keys;
      });
  in
    mergeAttrsList (mapKeys globals.${hostname}.secrets);

  hosts = builtins.readDir ./hosts;
  hostNames = builtins.attrNames hosts;

  mapSecrets = hs: forEach hs (hostname: makeSecrets hostname globals.${hostname}.keys);
in
  mergeAttrsList (mapSecrets hostNames)

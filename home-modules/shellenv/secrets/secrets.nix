let
  globals = {
    nixbook-air = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrJQiFW64lLJ2+90wQDNHtJhj2W++Z6h5RHuDuyCC9Tw4jqscin5tnJNy0TGSls3KpWaRsavOqRmW+zBSHXTEzUYp6TXIMvSVNS+K8hDmLeBNvxK41BbJjJ+uWSjufq4TrIpNwZIQo3uYCRQM3CgU65Mr4NlpjJ6rdAOBw9g0raYlIgNgdhs/ODE7TEsgQs+8Lsqy24BgGvxnEA1Pfkj1ZFacFsgz8TtMvvp7exgO+yyAeE1ZHN2eq3ISJVeBOSm6xzKm0s/S7Z86/QggJu58UOw7lxxKoYU2ToVd1Yp8gie9Ka9ptlRT/3VKUUiNVVKfc+uyHvMkN65iv6qFOYTd6LELGMdVZmc+9/RCmO41d5kxsNH/ce/eSGmRS0KIDtjaHD4PXNDINJjVTrx73psAz5nqe8XbUhTRsz9ht8MsAhx/jD+FN1hTKuzzXAIQw0LK1IS+GxymF6axgmZ00Tax8arrIc2sllhhD/HEhHLbYZg+23FMAM89PVUT55Bd0Pi5kU1dNNSzeclo2epe1cmrAdB7kqYrG6laFmQSlTlmxKrST9xhRgHrPECWFNhbEm2oImbh69mkD+HZ+70c4MDEmNuobR7jtNcylAJlcsQ+S6UQT1KKWIYPGnqjnBM2n6HNgHNofjbcAaVIQalv4+4urSUb8ebtQpGM/qUsjLiVQlQ== krad246@gmail.com"
    ];

    dullahan = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6l2JiQc7eHmYcdpXUcqqtL0l8DuicLhl4CeYul/jyD krad246@gmail.com"
    ];
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
    files = builtins.readDir ./hosts/${hostname};
    fileNames =
      builtins.attrNames files;

    mapKeys = fs:
      forEach fs (filename: {
        "./hosts/${hostname}/${filename}".publicKeys = keys;
      });
  in
    mergeAttrsList (mapKeys fileNames);

  hosts = builtins.readDir ./hosts;
  hostNames = builtins.attrNames hosts;

  mapSecrets = hs: forEach hs (hostname: makeSecrets hostname globals.${hostname});
in
  mergeAttrsList (mapSecrets hostNames)

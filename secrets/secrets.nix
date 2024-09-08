let
  globals = {
    nixbook-air = {
      secrets = [
        "cachix"
        "gh"
        "id_ed25519_priv"
        "id_ed25519_pub"
      ];

      keys = [
        # krad246@nixbook-air
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"

        # root@nixbook-air
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7/zqo4VsyDk/760jQaV6GLJ40E4+ETMJPexWmsQOPc root@nixbook-air"
      ];
    };

    dullahan = {
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

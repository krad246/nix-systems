let
  gremlin = {
    root = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0IJSgLQ/JomKuYZVV5/ZuboysqBJQCgBcHTvKklQDb root@gremlin";
    };
  };

  inherit (gremlin) root;
in {
  "binary-caches.age".publicKeys = [root.ed25519];
  "cluster-join-token.age".publicKeys = [root.ed25519];

  "./binary-caches.age".publicKeys = [root.ed25519];
  "./cluster-join-token.age".publicKeys = [root.ed25519];
}

let
  gremlin = {
    root = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0IJSgLQ/JomKuYZVV5/ZuboysqBJQCgBcHTvKklQDb root@gremlin";
    };
  };

  inherit (gremlin) root;
in {
  "gremlin/binary-caches.age".publicKeys = [root.ed25519];
  "gremlin/cluster-join-token.age".publicKeys = [root.ed25519];
  "gremlin/secrets.age".publicKeys = [root.ed25519];

  "./gremlin/binary-caches.age".publicKeys = [root.ed25519];
  "./gremlin/cluster-join-token.age".publicKeys = [root.ed25519];
  "./gremlin/secrets.age".publicKeys = [root.ed25519];

  "smeagol/binary-caches.age".publicKeys = [root.ed25519];
  "smeagol/cluster-join-token.age".publicKeys = [root.ed25519];
  "smeagol/tailscale-auth-key.age".publicKeys = [root.ed25519];

  "./smeagol/binary-caches.age".publicKeys = [root.ed25519];
  "./smeagol/cluster-join-token.age".publicKeys = [root.ed25519];
  "./smeagol/tailscale-auth-key.age".publicKeys = [root.ed25519];
}

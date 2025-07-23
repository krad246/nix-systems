let
  dullahan = {
    root = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXafRdLT+qPTMUzzMc35PxOP4zun6zIPTf98jQ6Bv5P";
    };
  };

  inherit (dullahan) root;
in {
  "dullahan/binary-caches.age".publicKeys = [root.ed25519];
  "dullahan/cluster-join-token.age".publicKeys = [root.ed25519];
  "dullahan/secrets.age".publicKeys = [root.ed25519];

  "./dullahan/binary-caches.age".publicKeys = [root.ed25519];
  "./dullahan/cluster-join-token.age".publicKeys = [root.ed25519];
  "./dullahan/secrets.age".publicKeys = [root.ed25519];

  "headless-penguin/binary-caches.age".publicKeys = [root.ed25519];
  "headless-penguin/cluster-join-token.age".publicKeys = [root.ed25519];
  "headless-penguin/tailscale-auth-key.age".publicKeys = [root.ed25519];

  "./headless-penguin/binary-caches.age".publicKeys = [root.ed25519];
  "./headless-penguin/cluster-join-token.age".publicKeys = [root.ed25519];
  "./headless-penguin/tailscale-auth-key.age".publicKeys = [root.ed25519];
}

let
  fortress = {
    root = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg9s+XAwWrvRf0k16ua9/3tpxbohrTGJEp4rOPnqgOh root@fortress";
    };
  };
  inherit (fortress) root;
in {
  "./hercules-ci-agent/binary-caches.age".publicKeys = [root.ed25519];
  "./hercules-ci-agent/cluster-join-token.age".publicKeys = [root.ed25519];
  "./hercules-ci-agent/secrets.age".publicKeys = [root.ed25519];
  "./cachix.age".publicKeys = [root.ed25519];
}

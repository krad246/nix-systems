let
  dullahan = {
    system = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXafRdLT+qPTMUzzMc35PxOP4zun6zIPTf98jQ6Bv5P";
    };

    linux-builder = {
      ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb root@nixos";
    };
  };

  inherit (dullahan) system linux-builder;
in {
  "./hercules-ci/headless-penguin/headless-penguin-binary-caches.age".publicKeys = [system.ed25519 linux-builder.ed25519];
  "./hercules-ci/headless-penguin/headless-penguin-cluster-join-token.age".publicKeys = [system.ed25519 linux-builder.ed25519];

  "./hercules-ci/dullahan-binary-caches.age".publicKeys = [system.ed25519];
  "./hercules-ci/dullahan-cluster-join-token.age".publicKeys = [system.ed25519];
}

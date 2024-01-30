let
  # System / privileged identity per host.
  root = {
    nixbook-air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7/zqo4VsyDk/760jQaV6GLJ40E4+ETMJPexWmsQOPc";
  };

  # User identities per host.
  krad246 = {
    immutable-gnome = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKd83MiKefYk702WTPhimblIQGsZKcNDlnhwuYjqDgo";
    nixos-wsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk51a/d6J53YyN4N6Q5gstkup07dPlQzIS/QiBzoMzg";
    nixbook-air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1";
  };
  # Secrets listed below list the identities allowed to unlock them.
in {
  # Github CLI login in userspace
  "gh.age".publicKeys = with krad246; [immutable-gnome nixos-wsl nixbook-air];

  # Cryptsetup password file
  "cryptsetup.age".publicKeys = with root; [nixbook-air];
}

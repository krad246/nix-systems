let
  krad246 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnXYLXHf5YatmbglLujnTScz1xe7rjPRWXRpGydx4Hb";
in {
  "github-access-token.age".publicKeys = [krad246];
}

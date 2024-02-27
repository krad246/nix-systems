let
  krad246 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwAZo8aBnpAkEef523koPMvShIyGDFxJGdEV9C4P3H9";
in {
  "gh.age".publicKeys = [krad246];
  "cryptsetup.age".publicKeys = [krad246];
}

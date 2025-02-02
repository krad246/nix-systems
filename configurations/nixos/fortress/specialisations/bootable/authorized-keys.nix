{
  self,
  specialArgs,
  lib,
  ...
}: {
  imports = [self.nixosModules.sshd];

  users.users.krad246.openssh.authorizedKeys.keys = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "pub" ./authorized_keys;
  in
    lib.lists.forEach paths (path: builtins.readFile path);

  programs.ssh = {
    startAgent = true;
  };
}

{
  self,
  lib,
  specialArgs,
  ...
}: {
  imports = with self.darwinModules; [
    agenix
    sshd
    wake-on-lan
  ];

  users.users.krad246.openssh.authorizedKeys.keys = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "pub" ./authorized_keys;
  in
    lib.lists.forEach paths (path: builtins.readFile path);

  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ./secrets/krad246;
  in
    krad246.attrsets.genAttrs' paths (path:
      krad246.attrsets.stemValuePair path {
        file = path;
      });
}

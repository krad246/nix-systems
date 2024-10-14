{
  self,
  inputs,
  ...
}: let
  inherit (inputs) agenix;
in {
  imports = [agenix.nixosModules.age] ++ [self.modules.generic.agenix];
  age = {
    identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}

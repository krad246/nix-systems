{inputs, ...}: let
  inherit (inputs) agenix;
in {
  imports = [agenix.nixosModules.age] ++ [../secrets];
  age = {
    identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}

{inputs, ...}: let
  inherit (inputs) agenix;
in {
  imports = [agenix.nixosModules.age] ++ [../../secrets];
}

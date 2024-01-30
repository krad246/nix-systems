{inputs, ...}: let
  inherit (inputs) agenix;
in {
  imports = [agenix.homeManagerModules.age];
  age = {
    secrets.gh.file = ../secrets/gh.age;
  };
}

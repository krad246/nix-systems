{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.agenix.homeManagerModules.age];
  home.packages = [
    pkgs.krad246.agenix
  ];
}

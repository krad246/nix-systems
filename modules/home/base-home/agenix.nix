{
  withSystem,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.agenix.homeManagerModules.age];
  home.packages = [
    (withSystem pkgs.stdenv.system ({inputs', ...}:
        inputs'.agenix.packages.default))
  ];
}

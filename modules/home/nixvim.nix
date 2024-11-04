{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.nixvim-config.packages.${pkgs.stdenv.system}.default
  ];
}

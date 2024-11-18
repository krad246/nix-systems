{
  self,
  inputs,
  inputs',
  pkgs,
  ...
}: {
  apps = {
    bootstrap = import ./bootstrap.nix {inherit inputs' pkgs;};
    devour-flake = import ./devour-flake.nix {inherit self inputs pkgs;};
  };
}

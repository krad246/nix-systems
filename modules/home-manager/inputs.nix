{
  inputs,
  self,
  lib,
  ...
}: {
  imports = lib.lists.optionals (inputs ? home-manager) [
    inputs.home-manager.flakeModules.default
  ];

  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.homeModules = self.modules.homeManager;
}

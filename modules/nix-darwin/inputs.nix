{
  inputs,
  self,
  lib,
  ...
}: {
  imports = lib.lists.optionals (inputs ? nix-darwin) [
    # inputs.nix-darwin.flakeModules.default
  ];

  flake-file.inputs = {
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.darwinModules = self.modules.darwin;
}

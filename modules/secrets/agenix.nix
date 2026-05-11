{inputs, ...}: {
  flake-file.inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules = {
    darwin.agenix = {
      imports = [inputs.agenix.darwinModules.age];
    };

    homeManager.agenix = {
      imports = [inputs.agenix.homeManagerModules.age];
    };

    nixos.agenix = {
      imports = [inputs.agenix.nixosModules.age];
    };
  };
}

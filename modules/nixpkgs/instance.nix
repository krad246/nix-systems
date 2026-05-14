{inputs, ...}: {
  flake.modules = {
    darwin.nixpkgs-instance = {
      nixpkgs = {
        source = inputs.nixpkgs;
        flake.source = inputs.nixpkgs.outPath;
      };
    };

    nixos.nixpkgs-instance = {
      nixpkgs.flake.source = inputs.nixpkgs.outPath;
    };
  };
}

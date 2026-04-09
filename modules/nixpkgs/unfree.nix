{
  flake = {
    modules = {
      darwin.nixpkgs-unfree = {
        nixpkgs.config.allowUnfree = true;
      };

      homeManager.nixpkgs-unfree = {
        nixpkgs.config.allowUnfree = true;
      };

      nixos.nixpkgs-unfree = {
        nixpkgs.config.allowUnfree = true;
      };
    };
  };
}

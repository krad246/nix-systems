{
  flake-file.inputs = {
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}

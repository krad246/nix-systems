{inputs, ...}: {
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.theme = {lib, ...}: {
    imports = [inputs.stylix.nixosModules.stylix];

    stylix = {
      enable = lib.modules.mkDefault true;
      autoEnable = false;
    };
  };
}

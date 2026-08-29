{
  imports = [
    ./flake-module.nix
    ./host-declarations.nix
    ./system-coordinates.nix
    ./system-outputs.nix
    ./home-manager-outputs.nix
    ./package-projections.nix
    ./configurations.nix
    ./tests/assertions.nix
    ./tests/home-manager-variants.nix
    ./tests/system-projections.nix
  ];
}

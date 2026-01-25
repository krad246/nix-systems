inputs:
inputs.flake-parts.lib.mkFlake {
  inherit inputs;
} {
  imports = [
    ./modules/inputs.nix
  ];
}

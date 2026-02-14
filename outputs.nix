inputs:
inputs.flake-parts.lib.mkFlake {
  inherit inputs;
} {
  imports = [
    ./modules/inputs.nix
    ./modules/flake/flake-compat.nix
    ./modules/flake/flake-root.nix
    ./modules/flake/pre-commit.nix
    ./modules/flake/treefmt.nix
    ./modules/flake/justfile.nix
    ./modules/flake/agenix-shell.nix
    ./modules/flake/devshell.nix
  ];
}

{withSystem, ...}: _: {
  imports = [
    ./containers
    ./devshell.nix
    ./apps/eater.nix
    ./formatter.nix
    ./just-flake.nix
    ./multiarch.nix
    ./tests.nix
  ];

  perSystem = {pkgs, ...}: {
    apps.bootstrap = withSystem pkgs.stdenv.system (import ./apps/bootstrap.nix);
  };

  flake = {
  };
}

{withSystem, ...}: _: {
  imports = [
    ./containers
    ./devshell.nix
    ./eater.nix
    ./formatter.nix
    ./just-flake.nix
    ./multiarch.nix
    ./tests.nix
  ];

  perSystem = {pkgs, ...}: {
    apps.bootstrap = withSystem pkgs.stdenv.system (args:
      import ./bootstrap.nix
      args);
  };

  flake = {
  };
}

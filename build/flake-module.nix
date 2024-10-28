_: _: {
  imports = [
    ./bootstrap.nix
    ./containers
    ./devshell.nix
    ./eater.nix
    ./formatter.nix
    ./just-flake.nix
    ./multiarch.nix
    ./tests.nix
  ];

  perSystem = _: {
  };

  flake = {
  };
}

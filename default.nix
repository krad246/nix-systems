{
  system ? builtins.currentSystem,
  flake ? true,
  ...
}: let
  flake-compat = let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  in
    fetchTarball {
      url = lock.nodes.flake-compat.locked.url or "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
      sha256 = lock.nodes.flake-compat.locked.narHash;
    };

  load-flake =
    import flake-compat {src = ./.;};

  inherit (load-flake) defaultNix;
in
  if flake
  then defaultNix
  else defaultNix.outputs.legacyPackages.${system}

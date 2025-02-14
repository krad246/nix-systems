{
  config,
  lib,
  pkgs,
  ...
}: {
  # Expose the internal flake registry to the filesystem, so that we
  # *always* have a local copy of all of our inputs.
  environment.etc = let
    mapFlakePath = name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    };
    mapRegistryPaths = registry: lib.attrsets.mapAttrs' mapFlakePath registry;
  in
    mapRegistryPaths
    config.nix.registry;

  # This will make the nix daemon prefer the flakes we JUST added
  # to the registry as its default 'include path' set.
  nix.nixPath = ["/etc/nix/path"];

  # nix-darwin manually sets up the flake registry with nixpkgs for us.
  nixpkgs.flake = lib.modules.mkIf pkgs.stdenv.isDarwin rec {
    setFlakeRegistry = false;
    setNixPath = setFlakeRegistry;
  };
}

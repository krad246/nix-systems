{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = let
      isFlake = _: lib.types.isType "flake";
      flakes = lib.attrsets.filterAttrs isFlake inputs;
      mkRegistry = flakes: lib.attrsets.mapAttrs (_key: flake: {inherit flake;}) flakes;
    in
      mkRegistry flakes;

    # This will make the nix daemon prefer the flakes we JUST added
    # to the registry as its default 'include path' set.
    nixPath = ["/etc/nix/path"];
  };

  # nix-darwin manually sets up the flake registry with nixpkgs for us.
  nixpkgs.flake = lib.modules.mkIf pkgs.stdenv.isDarwin rec {
    setFlakeRegistry = false;
    setNixPath = setFlakeRegistry;
  };

  # Expose the internal flake registry to the filesystem, so that we
  # *always* have a local copy of all of our inputs.
  environment.etc = let
    mapFlakePath = name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    };
    mapRegistryPaths = registry: lib.mapAttrs' mapFlakePath registry;
  in
    mapRegistryPaths
    config.nix.registry;
}

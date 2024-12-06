{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) attrsets modules types;
in {
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = let
      isFlake = _: types.isType "flake";
      flakes = attrsets.filterAttrs isFlake inputs;
      mkRegistry = flakes: attrsets.mapAttrs (_key: flake: {inherit flake;}) flakes;
    in
      mkRegistry flakes;

    # This will make the nix daemon prefer the flakes we JUST added
    # to the registry as its default 'include path' set.
    nixPath = ["/etc/nix/path"];
  };

  # nix-darwin manually sets up the flake registry with nixpkgs for us.
  nixpkgs.flake = modules.mkIf pkgs.stdenv.isDarwin rec {
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
    mapRegistryPaths = registry: attrsets.mapAttrs' mapFlakePath registry;
  in
    mapRegistryPaths
    config.nix.registry;
}

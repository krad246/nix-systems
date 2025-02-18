{
  config,
  lib,
  ...
}: {
  # Expose the internal flake registry to the filesystem, so that we
  # *always* have a local copy of all of our inputs.
  home.file = let
    mapFlakePath = name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    };
    mapRegistryPaths = registry: lib.attrsets.mapAttrs' mapFlakePath registry;
  in
    mapRegistryPaths
    config.nix.registry;
}

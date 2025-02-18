{
  inputs,
  lib,
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
  };
}

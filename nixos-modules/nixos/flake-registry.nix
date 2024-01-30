{
  inputs,
  config,
  lib,
  ...
}: let
  isFlake = _: lib.isType "flake";
  inputFlakes = lib.filterAttrs isFlake inputs;
in {
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) inputFlakes;

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;
}

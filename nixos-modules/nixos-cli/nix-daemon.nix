{
  config,
  modulesPath,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];

  nix = {
    package = pkgs.nixFlakes;
    checkConfig = true;
    gc.automatic = true;
    settings = {
      auto-optimise-store = true;
      sandbox = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      eval-cache = false
    '';

    # TODO: do something to unite the legacy and flake interfaces
    # nixPath = options.nix.nixPath.default ++ ["nixos-config=/etc/nixos"];
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

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

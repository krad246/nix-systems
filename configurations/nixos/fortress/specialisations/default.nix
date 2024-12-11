{
  inputs,
  self,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: rec {
  default = fortress;
  fortress.configuration = _: let
    inherit self;
  in {
    imports =
      [self.diskoConfigurations.fortress-desktop]
      ++ (let
        desktop = ./desktop;
      in [
        (desktop + "/authorized-keys.nix")
        (desktop + "/cachix-agent.nix")
        (import (desktop + "/hardware-configuration.nix") {inherit inputs self config lib pkgs modulesPath;}) # pre-apply args
        (desktop + "/secrets.nix")
        (desktop + "/settings.nix")
      ]);
  };
}

{self, ...}: rec {
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
        (desktop + "/hardware-configuration.nix")
        (desktop + "/secrets.nix")
        (desktop + "/settings.nix")
      ]);
  };
}

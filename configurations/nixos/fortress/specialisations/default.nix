args @ {
  importApply,
  self,
  ...
}: rec {
  default.configuration = fortress.configuration;
  fortress.configuration = _: {
    imports =
      [self.diskoConfigurations.fortress-desktop]
      ++ (let
        desktop = ./desktop;
      in [
        (desktop + "/authorized-keys.nix")
        (desktop + "/cachix-agent.nix")
        (importApply (desktop + "/hardware-configuration.nix") args)
        (desktop + "/hercules-ci-agent.nix")
        (desktop + "/secrets.nix")
        (desktop + "/settings.nix")
      ]);
  };
}

args @ {
  importApply,
  self,
  ...
}: let
  shared = {
    imports = [
      (importApply ./efiboot.nix args)
      (importApply ./hardware-configuration.nix args)
      self.diskoConfigurations.fortress-desktop
    ];
  };
in rec {
  desktop.configuration = _: let
    desktop = ./desktop;
    ci-agent = ./ci-agent;
  in {
    imports =
      [shared]
      ++ [
        (desktop + "/configuration.nix")
        (desktop + "/system-settings.nix")
        (ci-agent + "/authorized-keys.nix")
      ];
  };

  ci-agent.configuration = _: let
    ci-agent = ./ci-agent;
  in {
    imports =
      [shared]
      ++ [
        self.nixosModules.agenix
        (ci-agent + "/agenix.nix")
        (ci-agent + "/authorized-keys.nix")
        (ci-agent + "/cachix-agent.nix")
        (ci-agent + "/hercules-ci-agent.nix")
      ];
  };
}

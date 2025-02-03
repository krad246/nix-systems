{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    apps
    colima
  ];

  krad246.darwin = {
    apps.arc = false;

    virtualisation = rec {
      colima = {
        enable = true;
        inherit (config.krad246.darwin.virtualisation.linux-builder) memorySize;
        inherit (config.krad246.darwin.virtualisation.linux-builder) diskSize;
        inherit (config.krad246.darwin.virtualisation.linux-builder) cores;
      };
    };
  };

  # enable Lorri daemon for nix-direnv
  services.lorri.enable = true;
}

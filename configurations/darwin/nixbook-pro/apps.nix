{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    bluesnooze
    colima
    groupme
    magnet
    signal
    utm
    zoom
    zen-browser
  ];

  krad246.darwin = {
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

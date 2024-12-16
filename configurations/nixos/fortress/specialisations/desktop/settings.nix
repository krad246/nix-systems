{self, ...}: {
  imports = with self.nixosModules; [
    aarch64-binfmt
    avahi
    bluetooth
    kdeconnect
    pipewire
    rdp
    sshd
    system76-scheduler
  ];

  programs.ssh = {
    startAgent = true;
  };

  home-manager.sharedModules = [
    ({
      config,
      lib,
      ...
    }: let
      hasCfg = lib.attrsets.hasAttrByPath ["specialisation" "fortress"] config;
      cfg = config.specialisation.fortress.configuration;
    in {
      specialisation = {
        fortress = {
          configuration = _: {
            # TODO: must inherit settings from generic-linux
            imports = with self.homeModules; [
              discord
              kdeconnect
              vscode
              vscode-server
            ];

            services = {
              flatpak = {
                packages = [
                  "us.zoom.Zoom"
                  "org.signal.Signal"
                  "com.spotify.Client"
                  "com.valvesoftware.Steam"
                ];
              };
            };
          };
        };
      };

      home.activation = {
        switchToFortress = lib.modules.mkIf hasCfg (lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD ${cfg.home.activationPackage}
        '');
      };
    })
  ];
}

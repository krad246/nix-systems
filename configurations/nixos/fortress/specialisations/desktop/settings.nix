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
    ({lib, ...}: {
      specialisation = rec {
        default = lib.modules.mkForce fortress;
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
    })
  ];
}

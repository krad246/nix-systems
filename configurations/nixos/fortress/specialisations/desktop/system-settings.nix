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

  systemd.services.NetworkManager-wait-online.enable = false;

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=yes
  '';

  nix.settings.max-substitution-jobs = 144;

  virtualisation.docker.enable = true;

  users.users.krad246.extraGroups = ["docker"];

  home-manager.sharedModules = let
    fortress = {
      configuration = {...}: {
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
  in [
    ({lib, ...}: {
      imports = [
        fortress.configuration
      ];
      specialisation = rec {
        default = lib.modules.mkForce fortress;
        inherit fortress;
      };
    })
  ];
}

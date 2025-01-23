{self, ...}: {
  imports =
    [self.modules.generic.unfree]
    ++ (with self.nixosModules; [
      flatpak
      nixos
      opengl
    ])
    ++ (with self.nixosModules; [
      aarch64-binfmt
      bluetooth
      kdeconnect
      pipewire
      rdp
      system76-scheduler
    ]);

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

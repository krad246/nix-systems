{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.base = {pkgs, ...}: {
      imports = with self.modules.homeManager; [
        identity
        input-registry # overridable
        shell
      ];

      config = lib.modules.mkMerge [
        {
          home = {
            preferXdgDirectories = true;
            stateVersion = lib.trivial.release;
          };

          news.display = "silent";
        }
        (lib.modules.mkIf pkgs.stdenv.hostPlatform.isLinux {
          # FIXME: once intel-media-driver is conditionally included for x86_64-linux,
          # consider re-enabling targets.genericLinux.gpu.drivers
          targets.genericLinux = {
            enable = true;
            gpu.enable = lib.modules.mkDefault false;
          };
          systemd.user.startServices = "sd-switch";
        })
      ];
    };

    nixos.base = {
      imports = with self.modules.nixos; ([
          home-manager
          input-registry
          nix
          nixpkgs-instance
          owner
        ]
        ++ [
          # hardware
          locale
        ]);

      environment = {
        homeBinInPath = true;
        localBinInPath = true;
      };

      # nix.settings.trusted-users = ["@wheel"];

      # security.sudo = {
      #   # execWheelOnly = true;
      #   wheelNeedsPassword = lib.modules.mkDefault true;
      # };

      system.stateVersion = lib.trivial.release;
    };

    darwin.base = {
      imports = with self.modules.darwin; [
        home-manager
        input-registry
        nix
        nixpkgs-instance
        owner
      ];

      system.stateVersion = 6;
    };
  };
}

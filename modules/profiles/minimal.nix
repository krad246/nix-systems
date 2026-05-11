{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.minimal = {pkgs, ...}: {
      imports = with self.modules.homeManager; [
        # helix # TODO: editor backend interface
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

    nixos.minimal = {
      imports = with self.modules.nixos; [
        # hardware
        home-manager
        input-registry
        locale
        nix
        nixpkgs-instance
        owner
      ];

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

    darwin.minimal = {
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

{lib, ...}: {
  flake.modules = {
    darwin.zen-browser = {
      homebrew.casks = ["zen"];
    };

    homeManager.zen-browser = {pkgs, ...}: {
      config = lib.modules.mkMerge [
        (lib.modules.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          home.sessionVariables.BROWSER = let
            opener = pkgs.writeShellApplication {
              name = "zen-browser-open";
              text = ''
                exec open -a Zen "$@"
              '';
            };
          in
            lib.meta.getExe opener;
        })
        (lib.modules.mkIf pkgs.stdenv.hostPlatform.isLinux {
          services.flatpak.packages = ["app.zen_browser.zen"];
        })
      ];
    };

    nixos.zen-browser = {
    };
  };
}

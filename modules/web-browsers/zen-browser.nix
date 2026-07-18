{lib, ...}: {
  flake.modules = {
    darwin.zen-browser = {config, ...}: {
      options.browser.backends.zen.enable =
        lib.options.mkEnableOption "Zen browser application backend";

      config = lib.modules.mkIf config.browser.backends.zen.enable {
        appStore = {
          applications.zen.homebrew-cask = {
            displayName = "Zen Browser";
            identifier = "zen";
            appPath = "/Applications/Zen.app";
          };

          installations.zen = lib.modules.mkDefault "homebrew-cask";
          backends.homebrew-cask.enable = true;
        };
      };
    };

    homeManager.zen-browser = {
      config,
      pkgs,
      ...
    }: {
      options.browser.backends.zen = {
        enable = lib.options.mkEnableOption "Zen browser backend";
        default = lib.options.mkEnableOption "Zen as the default browser";
      };

      config = lib.modules.mkIf config.browser.backends.zen.default {
        browser.default = {
          command = let
            opener = pkgs.writeShellApplication {
              name = "zen-browser-open";
              text = ''
                if command -v open >/dev/null 2>&1; then
                  exec open -a Zen "$@"
                fi

                exec flatpak run app.zen_browser.zen "$@"
              '';
            };
          in
            lib.meta.getExe opener;

          appPath =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Applications/Zen.app"
            else null;
        };
      };
    };

    nixos.zen-browser = {
    };
  };
}

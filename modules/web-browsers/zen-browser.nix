{
  self,
  lib,
  ...
}: {
  flake.modules = {
    darwin.zen-browser = {config, ...}: {
      imports = [self.modules.darwin.homebrew];

      options.browser.backends.zen.enable =
        lib.options.mkEnableOption "Zen browser application backend";

      config = {
        appManagement.backends.homebrew.enable =
          lib.modules.mkDefault config.browser.backends.zen.enable;

        homebrew.casks =
          lib.lists.optional config.browser.backends.zen.enable "zen";
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

{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;

    # Profile installed only
    package = lib.mkForce null;

    # Enterprise policies management
    policies = {
      DisableAppUpdate = true;
      DontCheckDefaultBrowser = true;
    };

    profiles.zen = {
      containers = import ./containers.nix;
      containersForce = true;

      extensions = {
        force = true;
        packages = with pkgs.krad246.firefox-addons; [
          bitwarden
          ghostery
          multi-account-containers
          vimium
        ];

        settings = {};
      };

      extraConfig = ''
      '';

      search = {
        default = "ddg";
        force = true;

        engines = {
          "GitHub" = {
            urls = [
              {template = "https://github.com/search?q={searchTerms}";}
            ];
            definedAliases = ["@gh" "@github"];
            icon = "https://github.githubassets.com/favicons/favicon.svg";
          };

          "Noogle" = {
            urls = [
              {template = "https://noogle.dev/q?term={searchTerms}";}
            ];
            definedAliases = ["@noogle"];
            icon = "https://noogle.dev/favicon.ico";
          };

          "NixOS Options" = {
            urls = [
              {template = "https://search.nixos.org/options?query={searchTerms}";}
            ];
            definedAliases = ["@nixopts" "@options"];
            icon = "https://nixos.org/favicon.ico";
          };

          "NixOS Packages" = {
            urls = [
              {template = "https://search.nixos.org/packages?query={searchTerms}";}
            ];
            definedAliases = ["@nixpkgs" "@pkgs"];
            icon = "https://nixos.org/favicon.ico";
          };
        };
      };

      settings =
        (import ./prefs.nix)
        // (import ./extension-prefs.nix);
    };
  };

  # Zen-specific files that HM firefox doesn't model—declare them into the profile path.
  home.file = let
    profile =
      if pkgs.stdenv.isDarwin
      then ./profiles/darwin
      else ./profiles/linux;
  in
    # Zen mods + UI customizations
    {
      "${config.programs.firefox.profilesPath}/${config.programs.firefox.profiles.zen.path}/chrome" = {
        source = "${profile}/chrome";
        recursive = true;
      };

      "${config.programs.firefox.profilesPath}/${config.programs.firefox.profiles.zen.path}/zen-themes.json" = {
        source = "${profile}/zen-themes.json";
      };

      "${config.programs.firefox.profilesPath}/${config.programs.firefox.profiles.zen.path}/xulstore.json" = {
        source = "${profile}/xulstore.json";
      };
    }
    # Zen keyboard shortcuts
    // {
      "${config.programs.firefox.profilesPath}/${config.programs.firefox.profiles.zen.path}/zen-keyboard-shortcuts.json" = {
        source = "${profile}/zen-keyboard-shortcuts.json";
      };
    };
}

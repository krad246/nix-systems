{
  withSystem,
  config,
  pkgs,
  lib,
  ...
}: let
  profilesRoot = ".zen";
  profileId = "nix.default-release";
  profilePath = "${config.home.homeDirectory}/${profilesRoot}/${profileId}";
in {
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
        packages = withSystem pkgs.stdenv.system ({inputs', ...}:
          with inputs'.nur.legacyPackages.repos; [
            rycee.firefox-addons.bitwarden
            rycee.firefox-addons.ghostery
            rycee.firefox-addons.multi-account-containers
            rycee.firefox-addons.vimium
          ]);

        settings = {};
      };

      extraConfig = ''
      '';

      path = profilePath;

      search = {
        default = "ddg";
        force = false;
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

      settings = (import ./prefs.nix) // (import ./extension-prefs.nix);
    };
  };

  # Zen-specific files that HM firefox doesn't model—declare them into the profile path.
  home.file =
    # Zen mods + UI customizations
    {
      "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/chrome" = {
        source = ./profiles/zen/qnu52oxt.keerad/chrome;
        recursive = true;
      };

      "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/zen-themes.json" = {
        source = ./profiles/zen/qnu52oxt.keerad/zen-themes.json;
      };

      "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/xulstore.json" = {
        source = ./profiles/zen/qnu52oxt.keerad/xulstore.json;
      };
    }
    # Zen keyboard shortcuts
    // {
      "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/zen-keyboard-shortcuts.json" = {
        source = ./profiles/zen/qnu52oxt.keerad/zen-keyboard-shortcuts.json;
      };
    };
}

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

    # Try profile-only (works on many channels); if it errors, remove this line.
    package = lib.mkForce null;

    # Optional global policies
    # Force-install add-ons in Zen via enterprise policies
    policies = {
      DisableAppUpdate = true;
      DontCheckDefaultBrowser = true;

      ExtensionSettings = {
        "@testpilot-containers" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          # Bitwarden
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
        "firefox@ghostery.com" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ghostery/latest.xpi";
        };
      };
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

      settings = (import ./prefs.nix) // (import ./extension-prefs.nix);

      # No custom CSS present
      # userChrome  = null;
      # userContent = null;
    };
  };

  # Zen-specific files that HM firefox doesn't model—declare them into the profile path.
  home.file = {
    # Write ~/.zen/profiles.ini to make Zen/Firefox start with this profile.
    # "${profilesRoot}/profiles.ini".text = builtins.readFile ./profiles.ini;

    "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/chrome" = {
      source = ./profiles/zen/qnu52oxt.keerad/chrome;
      recursive = true;
    };

    "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/handlers.json" = {
      source = ./profiles/zen/qnu52oxt.keerad/handlers.json;
    };

    "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/xulstore.json" = {
      source = ./profiles/zen/qnu52oxt.keerad/xulstore.json;
    };

    "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/zen-themes.json" = {
      source = ./profiles/zen/qnu52oxt.keerad/zen-themes.json;
    };

    "Library/Application Support/Firefox/Profiles/${config.home.homeDirectory}/${profilesRoot}/${profileId}/zen-keyboard-shortcuts.json" = {
      source = ./profiles/zen/qnu52oxt.keerad/zen-keyboard-shortcuts.json;
    };
  };
}

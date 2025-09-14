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

    profiles.zen = {
      path = profilePath;
      isDefault = true;

      # Core about:config prefs from your uploaded profile
      settings = import ./zen-prefs.nix;

      # Extensions available in nixpkgs
      extensions.packages = withSystem pkgs.stdenv.system ({inputs', ...}:
        with inputs'.nur.legacyPackages.repos; [
          rycee.firefox-addons.bitwarden
          rycee.firefox-addons.ghostery
          rycee.firefox-addons.multi-account-containers
          rycee.firefox-addons.vimium
        ]);

      # Simple search setup
      search = {
        default = "ddg";
        force = true;
        engines = {
          "ddg" = {
            urls = [{template = "https://duckduckgo.com/?q={searchTerms}";}];
          };
        };
      };

      # No custom CSS present in your upload—leave these null (or fill later)
      # userChrome  = null;
      # userContent = null;
    };

    # Optional global policies
    policies = {
      DisableAppUpdate = true;
      DontCheckDefaultBrowser = true;
    };
  };

  # Zen-specific files that HM firefox doesn't model—declare them into the profile path.
  home.file = {
    "${profilesRoot}/${profileId}/zen-keyboard-shortcuts.json".source = ./profiles/zen/qnu52oxt.keerad/zen-keyboard-shortcuts.json;

    "${profilesRoot}/${profileId}/zen-themes.json".source = ./profiles/zen/qnu52oxt.keerad/zen-themes.json;

    "${profilesRoot}/${profileId}/chrome/zen-themes.css".source = ./profiles/zen/qnu52oxt.keerad/chrome/zen-themes.css;

    # Write ~/.zen/profiles.ini to make Zen/Firefox start with this profile.
    "${profilesRoot}/profiles.ini".text = builtins.readFile ./profiles.ini;
  };
}

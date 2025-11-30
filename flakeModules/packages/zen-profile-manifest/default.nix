{
  lib,
  writeShellApplication,
  coreutils,
  ...
}: let
  inherit (lib) strings;

  manifest-files = [
    "places.sqlite"
    "cookies.sqlite"
    "cert9.db"
    "key4.db"
    "logins.json"
    "extension-preferences.json"
    "extensions.json"
    "extension-settings.json"
    "extensions"
    "search.json.mozlz4"
    "sessionCheckpoints.json"
    "sessionstore.jsonlz4"
    "prefs.js"
    "storage"
    "chrome"
    "addons.json"
    "zen-keyboard-shortcuts.json"
    "zen-themes.json"
    "containers.json"
  ];
  zen-profile-manifest = writeShellApplication {
    name = "zen-profile-manifest";

    runtimeInputs = [coreutils];

    text =
      /*
      bash
      */
      ''
        usage() {
          echo "Usage:" >&2
          echo "  zen-profile-manifest PROFILE_ROOT..." >&2
          echo "  zen-profile-manifest -      # read roots (one per line) from stdin" >&2
          exit 1
        }

        if [ "$#" -eq 0 ]; then
          usage
        fi

        files=( ${strings.concatMapStringsSep " " (x: strings.escapeShellArg x) manifest-files} )

        print_profile_manifest() {
          local profile="$1"
          local root
          root="$(realpath -m -- "$profile")"
          for f in "''${files[@]}"; do
            printf '%s\n' "$root/$f"
          done
        }

        roots=()

        # stdin mode
        if [ "$#" -eq 1 ] && [ "$1" = "-" ]; then
          while IFS=$'\n' read -r line; do
            [ -z "$line" ] && continue
            roots+=("$line")
          done
        else
          # arg list mode (forbid '-')
          for arg in "$@"; do
            if [ "$arg" = "-" ]; then
              echo "zen-profile-manifest: '-' cannot be mixed with explicit roots" >&2
              usage
            fi
            roots+=("$arg")
          done
        fi

        for profile in "''${roots[@]}"; do
          print_profile_manifest "$profile"
        done
      '';

    passthru = {
      inherit manifest-files;
    };
  };
in
  zen-profile-manifest
  // {
    passthru.tests = {
    };
  }

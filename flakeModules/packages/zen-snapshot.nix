{
  lib,
  writeShellApplication,
  findutils,
  bash,
  coreutils,
  ...
}: let
  inherit (lib) meta;
in
  writeShellApplication {
    name = "zen-snapshot";

    text = ''
            ${meta.getExe' findutils "xargs"} -r -I {} \
              ${meta.getExe bash} -c \
                '${meta.getExe' coreutils "cat"} <<- EOF
      {}/places.sqlite
      {}/cookies.sqlite
      {}/cert9.db
      {}/key4.db
      {}/logins.json
      {}/extension-preferences.json
      {}/extensions.json
      {}/extension-settings.json
      {}/extensions
      {}/search.json.mozlz4
      {}/sessionCheckpoints.json
      {}/sessionstore.jsonlz4
      {}/prefs.js
      {}/storage
      {}/chrome
      {}/addons.json
      {}/zen-keyboard-shortcuts.json
      {}/zen-themes.json
      {}/containers.json
      EOF'
    '';
  }

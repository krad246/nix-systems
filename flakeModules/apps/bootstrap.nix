{
  writeShellApplication,
  bashInteractive,
  git,
  coreutils,
  curl,
  xz,
  direnv,
  nix-direnv,
  nixVersions,
  flake-root,
  ...
}:
writeShellApplication {
  name = "bootstrap";
  runtimeInputs =
    [
      bashInteractive
      git
      coreutils
      curl
      xz
    ]
    ++ [
      direnv
      nix-direnv
    ]
    ++ [nixVersions.stable] ++ [flake-root];
  text = ''
    root="''${1:-$(${flake-root}/bin/flake-root)}"
    if [[ ! -f "$root/flake.nix" || ! -f "$root/.envrc" ]]; then
      printf 'bootstrap: invalid flake root: %s\n' "$root" >&2
      exit 1
    fi

    ${direnv}/bin/direnv allow "$root"
    ${direnv}/bin/direnv exec "$root" true
  '';
}

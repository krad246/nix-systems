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
    TOP="$(flake-root)"
    direnv allow "$TOP"
    direnv exec "$TOP" true
  '';
}

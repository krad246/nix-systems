{
  writeShellApplication,
  bash,
  coreutils,
  gawk,
  gnused,
  perl,
  flake-root,
  ...
}:
writeShellApplication {
  name = "agent-checkpoint";
  runtimeInputs = [bash coreutils gawk gnused perl];
  text = ''
    root="''${1:-$(${flake-root}/bin/flake-root)}"

    if [[ ! -f "$root/flake.nix" || ! -f "$root/.agents/dendritic/context.md" ]]; then
      printf 'agent-checkpoint: invalid context-bearing flake root: %s\n' "$root" >&2
      exit 1
    fi

    bash ${../../.agents/dendritic/context.sh} \
      --root "$root" \
      --bundle "$root/.agents/dendritic" \
      checkpoint
  '';
}

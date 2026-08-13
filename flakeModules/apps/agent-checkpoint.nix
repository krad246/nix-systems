{
  writeShellApplication,
  bash,
  coreutils,
  gawk,
  gnused,
  perl,
  ...
}:
writeShellApplication {
  name = "agent-checkpoint";
  runtimeInputs = [bash coreutils gawk gnused perl];
  text = ''
    root="''${FLAKE_ROOT:-}"
    if [[ ! -f "$root/flake.nix" || ! -f "$root/.agents/dendritic/context.md" ]]; then
      root="$PWD"
      while [[ "$root" != / && (! -f "$root/flake.nix" || ! -f "$root/.agents/dendritic/context.md") ]]; do
        root="''${root%/*}"
      done
    fi

    if [[ ! -f "$root/flake.nix" || ! -f "$root/.agents/dendritic/context.md" ]]; then
      printf 'agent-checkpoint: no context-bearing flake found from %s\n' "$PWD" >&2
      exit 1
    fi

    bash ${../../.agents/dendritic/context.sh} checkpoint "$root" "$root/.agents/dendritic"
  '';
}

#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
bundle="$root/.agents/dendritic"
context="$bundle/context.md"
routes="$bundle/routes.tsv"
manifest="$bundle/manifest"
bootstrap="$root/AGENTS.md"

digest() {
  (
    cd "$root"
    shasum -a 256 .agents/dendritic/context.md .agents/dendritic/routes.tsv
  ) | shasum -a 256 | awk '{print $1}'
}

section() {
  local heading="$1"
  awk -v wanted="$heading" '
    function level(line, copy) {
      copy = line
      sub(/[^#].*$/, "", copy)
      return length(copy)
    }
    /^#+ / {
      current = substr($0, level($0) + 2)
      if (printing && level($0) <= start_level) exit
      if (current == wanted) {
        printing = 1
        start_level = level($0)
      }
    }
    printing
  ' "$context"
}

lookup() {
  local key="$1"
  awk -F '\t' -v wanted="$key" '$1 == wanted {print $2; found=1} END {exit !found}' "$routes"
}

verify() {
  local actual expected
  actual="$(digest)"
  expected="$(awk -F= '$1 == "proxy-sha256" {print $2}' "$manifest")"
  if [[ -z "$expected" || "$actual" != "$expected" ]]; then
    printf 'STALE context bundle\nexpected: %s\nactual:   %s\nrun: %s refresh\n' \
      "${expected:-missing}" "$actual" "$0" >&2
    return 1
  fi
  printf '%s\n' "$actual"
}

refresh() {
  local hash tmp_manifest tmp_bootstrap
  hash="$(digest)"
  tmp_manifest="$(mktemp "${TMPDIR:-/tmp}/dendritic-manifest.XXXXXX")"
  tmp_bootstrap="$(mktemp "${TMPDIR:-/tmp}/dendritic-agents.XXXXXX")"
  trap 'rm -f "$tmp_manifest" "$tmp_bootstrap"' EXIT

  {
    printf 'format=dendritic-context-v1\n'
    printf 'proxy-sha256=%s\n' "$hash"
    printf 'canonical=.agents/dendritic/context.md\n'
    printf 'routes=.agents/dendritic/routes.tsv\n'
    printf 'generator=.agents/dendritic/context.sh\n'
  } >"$tmp_manifest"

  sed "s/@PROXY_SHA256@/$hash/g" "$bundle/AGENTS.template.md" >"$tmp_bootstrap"
  mv "$tmp_manifest" "$manifest"
  mv "$tmp_bootstrap" "$bootstrap"
  trap - EXIT
  printf 'refreshed %s\n' "$hash"
}

case "${1:-help}" in
  verify)
    verify
    ;;
  hash)
    digest
    ;;
  list)
    verify >/dev/null
    awk -F '\t' '!/^#/ {printf "%-16s %s\n", $1, $3}' "$routes"
    ;;
  read)
    verify >/dev/null
    [[ $# -ge 2 ]] || { printf 'usage: %s read ROUTE...\n' "$0" >&2; exit 2; }
    shift
    for key in "$@"; do
      heading="$(lookup "$key")" || { printf 'unknown route: %s\n' "$key" >&2; exit 2; }
      section "$heading"
    done
    ;;
  full)
    verify >/dev/null
    cat "$context"
    ;;
  refresh)
    refresh
    ;;
  help|*)
    cat <<EOF
Usage: $0 COMMAND

  verify          fail if canonical context/routes differ from the proxy hash
  hash            print the current canonical content hash
  list            list lazy context routes
  read ROUTE...   expand selected canonical sections
  full            expand the complete canonical context
  refresh         regenerate manifest and root AGENTS.md after canonical edits

For architecture changes, migration planning, or uncertainty, use 'full'.
EOF
    ;;
esac

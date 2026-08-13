#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
bundle="$root/.agents/dendritic"
context="$bundle/context.md"
routes="$bundle/routes.tsv"
manifest="$bundle/manifest"
bootstrap="$root/AGENTS.md"
cache_dir="${CODEX_CONFIG_DIR:-$HOME/.config/codex}/cache/project-charters"
cache_context="$cache_dir/dotfiles-dendritic-grand-vision.md"
cache_ledger="$cache_dir/dotfiles-nixbook-pro-closure-ledger.md"

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
	if [[ -z $expected || $actual != "$expected" ]]; then
		printf 'STALE context bundle\nexpected: %s\nactual:   %s\nrun: %s refresh\n' \
			"${expected:-missing}" "$actual" "$0" >&2
		return 1
	fi
	printf '%s\n' "$actual"
}

sync_cache() {
	mkdir -p "$cache_dir"
	cp "$context" "$cache_context"
	render_ledger >"$cache_ledger"
}

render_ledger() {
	local source_note gates
	# These are literal Markdown code spans, not attempted shell expansion.
	# shellcheck disable=SC2016
	source_note='Generated from `.agents/dendritic/context.md`; edit the repository context, not this mirror.'
	# shellcheck disable=SC2016
	gates='Acceptance gates for the `nixbook-pro` slice'
	{
		printf '# nixbook-pro closure ledger\n\n'
		printf '%s\n\n' "$source_note"
		section 'Explicit owner decisions: do not reopen without new direction'
		printf '\n'
		section 'Behavioral parity ledger (evidence as of this handoff)'
		printf '\n'
		section "$gates"
		printf '\n'
		section 'Immediate next work'
	}
}

verify_cache() {
	local tmp_ledger
	cmp -s "$context" "$cache_context" || {
		printf 'STALE local context mirror: %s\nrun: %s sync-cache\n' \
			"$cache_context" "$0" >&2
		return 1
	}
	tmp_ledger="$(mktemp "${TMPDIR:-/tmp}/dendritic-ledger.XXXXXX")"
	trap 'rm -f "$tmp_ledger"' EXIT
	render_ledger >"$tmp_ledger"
	cmp -s "$tmp_ledger" "$cache_ledger" || {
		printf 'STALE local closure-ledger mirror: %s\nrun: %s sync-cache\n' \
			"$cache_ledger" "$0" >&2
		return 1
	}
	trap - EXIT
	rm -f "$tmp_ledger"
	printf 'local cache mirrors match canonical context\n'
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
	sync_cache
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
	[[ $# -ge 2 ]] || {
		printf 'usage: %s read ROUTE...\n' "$0" >&2
		exit 2
	}
	shift
	for key in "$@"; do
		heading="$(lookup "$key")" || {
			printf 'unknown route: %s\n' "$key" >&2
			exit 2
		}
		section "$heading"
	done
	;;
full)
	verify >/dev/null
	cat "$context"
	;;
sync-cache)
	verify >/dev/null
	sync_cache
	;;
verify-cache)
	verify >/dev/null
	verify_cache
	;;
refresh)
	refresh
	;;
help | *)
	cat <<EOF
Usage: $0 COMMAND

  verify          fail if canonical context/routes differ from the proxy hash
  hash            print the current canonical content hash
  list            list lazy context routes
  read ROUTE...   expand selected canonical sections
  full            expand the complete canonical context
  refresh         regenerate proxy files and local cache mirrors after edits
  sync-cache      replace local cache mirrors from verified canonical context
  verify-cache    fail if local cache mirrors differ from canonical context

For architecture changes, migration planning, or uncertainty, use 'full'.
EOF
	;;
esac

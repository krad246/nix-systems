#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd -P)"

command -v git >/dev/null 2>&1 || {
	printf 'bootstrap: git is required before entering the Nix bootstrap app\n' >&2
	exit 1
}
command -v nix >/dev/null 2>&1 || {
	printf 'bootstrap: nix is required; run setup.sh instead\n' >&2
	exit 1
}

safe=false
while IFS= read -r directory; do
	[[ $directory == "$root" ]] && safe=true
done < <(git config --global --get-all safe.directory || true)
if [[ $safe == false ]]; then
	if [[ ! -t 0 ]]; then
		printf 'bootstrap: refusing to change global Git config without interactive approval\n' >&2
		exit 1
	fi
	read -r -p "Trust this checkout in global Git config? [y/N] " reply
	[[ $reply == [yY] ]] || exit 1
	git config --global --add safe.directory "$root"
fi

exec nix \
	--option experimental-features 'nix-command flakes' \
	run "$root#bootstrap" -- "$root" "$@"

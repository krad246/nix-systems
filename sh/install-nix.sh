#!/usr/bin/env bash

if ! command -v nix >/dev/null 2>&1; then
	command -v curl >/dev/null 2>&1 || {
		printf 'setup: curl is required to install Nix\n' >&2
		return 1
	}

	sh <(curl --fail --location --show-error https://nixos.org/nix/install) \
		--daemon --yes \
		--nix-extra-conf-file <(printf '%s\n' 'experimental-features = nix-command flakes')

	if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
		# shellcheck source=/dev/null
		. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
	fi
fi

command -v nix >/dev/null 2>&1 || {
	printf 'setup: Nix was installed but is unavailable in this shell\n' >&2
	return 1
}

#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

mode=write
case "${1-}" in
	--check)
		mode=check
		shift
		;;
esac

if [ "$#" -eq 0 ]; then
	exit 0
fi

for path; do
	case "$path" in
		/*)
			absolute_path=$path
			;;
		*)
			absolute_path=$REPO_ROOT/$path
			;;
	esac

	if [ "$mode" = check ]; then
		go run -C "$SCRIPT_DIR" mvdan.cc/sh/v3/cmd/shfmt -i 0 -ci -d "$absolute_path"
	else
		go run -C "$SCRIPT_DIR" mvdan.cc/sh/v3/cmd/shfmt -i 0 -ci -w "$absolute_path"
	fi
done

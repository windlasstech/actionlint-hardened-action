#!/bin/sh
set -eu

GIT=${GIT:-git}
EDITOR=${EDITOR:-${VISUAL:-}}

usage() {
	printf 'usage: %s VERSION\n' "$0" >&2
	exit 1
}

error() {
	printf 'error: %s\n' "$1" >&2
	exit 1
}

cleanup() {
	if [ -n "${message_file:-}" ]; then
		rm -f "$message_file"
	fi
	if [ -n "${backup_file:-}" ]; then
		rm -f "$backup_file"
	fi
}

message_file=
backup_file=
trap cleanup EXIT HUP INT TERM

if [ $# -ne 1 ]; then
	usage
fi

version_input=$1
case $version_input in
	v*)
		bare_version=${version_input#v}
		;;
	*)
		bare_version=$version_input
		;;
esac

old_ifs=$IFS
IFS=.
set -- $bare_version
IFS=$old_ifs

if [ $# -ne 3 ]; then
	error "invalid version '$version_input'"
fi

for part in "$1" "$2" "$3"; do
	case $part in
		'' | *[!0-9]*)
			error "invalid version '$version_input'"
			;;
	esac
done

bare_version=$1.$2.$3
tag_name=v$bare_version

if [ ! -f CHANGELOG.md ]; then
	error 'CHANGELOG.md not found'
fi

section_heading="## [$bare_version] - "
section_label="## [$bare_version] -"

if "$GIT" rev-parse -q --verify "refs/tags/$tag_name" >/dev/null 2>&1; then
	error "tag $tag_name already exists"
fi

if signing_key=$("$GIT" config --get user.signingkey 2>/dev/null); then
	if [ -z "$signing_key" ]; then
		error 'user.signingkey is not configured'
	fi
else
	error 'user.signingkey is not configured'
fi

message_file=${TMPDIR:-/tmp}/create-release-tag.$$

if awk -v heading="$section_heading" '
BEGIN {
	found = 0
	in_section = 0
	n = 0
	start = 0
	end = 0
}
index($0, heading) == 1 {
	found = 1
	in_section = 1
	next
}
found && in_section && (/^## \[/ || /^\[[^]]+\]:/) {
	in_section = 0
	next
}
found && in_section {
	lines[++n] = $0
	if ($0 ~ /[^[:space:]]/) {
		if (start == 0) {
			start = n
		}
		end = n
	}
}
END {
	if (!found) {
		exit 2
	}
	if (start == 0) {
		exit 3
	}
	for (i = start; i <= end; i++) {
		print lines[i]
	}
}
' CHANGELOG.md >"$message_file"; then
	:
else
	awk_status=$?
	case $awk_status in
		2)
			error "release section $section_label not found"
			;;
		3)
			error "release section $section_label is empty"
			;;
		*)
			error 'failed to extract release section'
			;;
	esac
fi

printf '\nThe following annotation will be used for tag %s:\n\n' "$tag_name"
cat "$message_file"
printf '\n'

while true; do
	printf 'Proceed? [e=edit / y=yes / n=no] '
	read -r choice
	case "$choice" in
		y | yes | Y | YES)
			break
			;;
		n | no | N | NO)
			echo 'Aborted.'
			exit 0
			;;
		e | edit | E | EDIT)
			if [ -z "$EDITOR" ]; then
				error 'EDITOR (or VISUAL) is not set'
			fi
			backup_file=${TMPDIR:-/tmp}/create-release-tag-backup.$$
			cp "$message_file" "$backup_file"
			"$EDITOR" "$message_file"
			printf '\nUpdated annotation:\n\n'
			cat "$message_file"
			printf '\n'
			;;
		*)
			printf 'Please enter y (yes), n (no), or e (edit).\n'
			;;
	esac
done

"$GIT" tag -s -a "$tag_name" -F "$message_file"

printf 'Created signed annotated tag %s\n' "$tag_name"

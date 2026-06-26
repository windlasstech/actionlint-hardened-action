#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_SCRIPT=$SCRIPT_DIR/create-release-tag.sh
REAL_GIT=$(command -v git)
TMP_ROOT=${TMPDIR:-/tmp}/create-release-tag.$$

PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
	rm -rf "$TMP_ROOT"
}

trap cleanup EXIT HUP INT TERM

mkdir "$TMP_ROOT"

make_repo() {
	name=$1
	changelog=$2
	set_signingkey=${3:-yes}
	existing_tag=${4:-}
	repo=$TMP_ROOT/$name
	mkdir "$repo"
	mkdir "$repo/bin"

	cat >"$repo/CHANGELOG.md" <<EOF
$changelog
EOF

	echo fixture >"$repo/README.md"

	(
		cd "$repo"
		git init >/dev/null 2>&1
		git config user.email test@example.invalid
		git config user.name Test User
		git config commit.gpgsign false
		if [ "$set_signingkey" = yes ]; then
			git config user.signingkey DEADBEEF
			touch "$repo/.signingkey"
		fi
		git add README.md CHANGELOG.md
		git commit -m 'fixture: initial commit' >/dev/null 2>&1
		if [ -n "$existing_tag" ]; then
			git tag "$existing_tag"
		fi

	)

	cat >"$repo/bin/git" <<'EOF'
#!/bin/sh
set -eu

REAL_GIT=__REAL_GIT__
REPO_ROOT=__REPO_ROOT__

if [ "${1-}" = config ] && [ "${2-}" = --get ] && [ "${3-}" = user.signingkey ]; then
	if [ -e "$REPO_ROOT/.signingkey" ]; then
		echo DEADBEEF
		exit 0
	fi
	exit 1
fi

if [ "${1-}" = tag ]; then
	shift
	create=no
	tag_name=
	message_file=
	case " $* " in
		*" -s "*|*" -a "*|*" -F "*)
			create=yes
			;;
	esac
	if [ "$create" = yes ]; then
		while [ $# -gt 0 ]; do
			case "$1" in
				-s|-a)
					shift
					;;
				-F)
					shift
					message_file=$1
					shift
					;;
				--)
					shift
					while [ $# -gt 0 ]; do
						if [ -z "$tag_name" ]; then
							tag_name=$1
						fi
						shift
					done
					break
					;;
				-*)
					shift
					;;
				*)
					if [ -z "$tag_name" ]; then
						tag_name=$1
					fi
					shift
					;;
			esac
		done
		if [ -n "$tag_name" ] && [ -n "$message_file" ]; then
			echo "$tag_name" >"$REPO_ROOT/recorded-tag"
			echo "$message_file" >"$REPO_ROOT/recorded-message-file"
			cp "$message_file" "$REPO_ROOT/recorded-message"
			exec "$REAL_GIT" tag -a "$tag_name" -F "$message_file"
		fi
	fi
fi

	exec "$REAL_GIT" "$@"
EOF
	sed -e "s|__REAL_GIT__|$REAL_GIT|g" -e "s|__REPO_ROOT__|$repo|g" "$repo/bin/git" >"$repo/bin/git.tmp"
	mv "$repo/bin/git.tmp" "$repo/bin/git"

	cat >"$repo/bin/editor" <<'EOF'
#!/bin/sh
set -eu

message_file=$1
printf '%s\n' '--- edited by fake editor ---' >>"$message_file"
EOF

	chmod +x "$repo/bin/git"
	chmod +x "$repo/bin/editor"
	echo "$repo"
}

run_script() {
	repo=$1
	shift
	(
		cd "$repo"
		GIT="$repo/bin/git" sh "$TARGET_SCRIPT" "$@"
	)
}

run_script_with_input() {
	repo=$1
	input=$2
	editor=${3-}
	shift 3
	(
		cd "$repo"
		if [ -n "$editor" ]; then
			EDITOR=$editor
			export EDITOR
		fi
		printf '%s' "$input" | GIT="$repo/bin/git" sh "$TARGET_SCRIPT" "$@"
	)
}

pass() {
	PASS_COUNT=$((PASS_COUNT + 1))
	echo "ok - $1"
}

fail() {
	FAIL_COUNT=$((FAIL_COUNT + 1))
	echo "not ok - $1: $2" >&2
}

check_success() {
	test_name=$1
	shift
	if "$@"; then
		pass "$test_name"
	else
		fail "$test_name" 'expected success'
	fi
}

check_failure() {
	test_name=$1
	shift
	if "$@"; then
		pass "$test_name"
	else
		fail "$test_name" 'expected failure'
	fi
}

repo_has_no_recorded_tag() {
	repo=$1
	[ ! -e "$repo/recorded-tag" ]
}

repo_recorded_tag_is() {
	repo=$1
	expected=$2
	actual=$(cat "$repo/recorded-tag")
	[ "$actual" = "$expected" ]
}

repo_recorded_message_has() {
	repo=$1
	needle=$2
	grep -F -- "$needle" "$repo/recorded-message" >/dev/null 2>&1
}

repo_recorded_message_lacks() {
	repo=$1
	needle=$2
	if grep -F -- "$needle" "$repo/recorded-message" >/dev/null 2>&1; then
		return 1
	fi
	return 0
}

repo_recorded_message_has_marker() {
	repo=$1
	grep -F -- '--- edited by fake editor ---' "$repo/recorded-message" >/dev/null 2>&1
}

test_normalizes_plain_version_to_v_tag() {
	repo=$(make_repo normalizes-version "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	run_script_with_input "$repo" 'y
' '' 1.0.0 >/dev/null 2>&1 || return 1
	repo_recorded_tag_is "$repo" v1.0.0
}

test_preserves_prefixed_version() {
	repo=$(make_repo preserves-prefixed-version "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	run_script_with_input "$repo" 'y
' '' v1.0.0 >/dev/null 2>&1 || return 1
	repo_recorded_tag_is "$repo" v1.0.0
}

test_extracts_annotation_body_until_next_heading() {
	repo=$(make_repo extracts-annotation-body "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	run_script_with_input "$repo" 'y
' '' 1.0.0 >/dev/null 2>&1 || return 1
	repo_recorded_message_has "$repo" '- Added alpha' &&
		repo_recorded_message_has "$repo" '- Added beta' &&
		repo_recorded_message_lacks "$repo" '## [0.9.0]'
}

test_accepts_yes_to_create_tag() {
	repo=$(make_repo accepts-yes-to-create-tag "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	run_script_with_input "$repo" 'y
' '' 1.0.0 >/dev/null 2>&1 || return 1
	repo_recorded_tag_is "$repo" v1.0.0
}

test_rejects_no_without_creating_tag() {
	repo=$(make_repo rejects-no-without-creating-tag "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	run_script_with_input "$repo" 'n
' '' 1.0.0 >/dev/null 2>&1 || return 1
	repo_has_no_recorded_tag "$repo"
}

test_opens_editor_and_uses_edited_annotation() {
	repo=$(make_repo opens-editor-and-uses-edited-annotation "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	run_script_with_input "$repo" 'e
y
' "$repo/bin/editor" 1.0.0 >/dev/null 2>&1 || return 1
	repo_recorded_tag_is "$repo" v1.0.0 &&
		repo_recorded_message_has_marker "$repo"
}

test_editor_missing_fails() {
	repo=$(make_repo editor-missing-fails "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	if run_script_with_input "$repo" 'e
' '' 1.0.0 >/dev/null 2>&1; then
		return 1
	fi
	repo_has_no_recorded_tag "$repo"
}

test_invalid_input_then_yes_creates_tag() {
	repo=$(make_repo invalid-input-then-yes-creates-tag "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	run_script_with_input "$repo" 'maybe
y
' '' 1.0.0 >/dev/null 2>&1 || return 1
	repo_recorded_tag_is "$repo" v1.0.0
}

test_existing_tag_fails_before_creating_tag() {
	repo=$(make_repo existing-tag-fails "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
" yes v1.0.0)
	if run_script "$repo" 1.0.0 >/dev/null 2>&1; then
		return 1
	fi
	repo_has_no_recorded_tag "$repo"
}

test_missing_section_fails() {
	repo=$(make_repo missing-section "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha

## [0.9.0] - 12026-06-20
- Older note
")
	if run_script "$repo" 1.0.1 >/dev/null 2>&1; then
		return 1
	fi
	repo_has_no_recorded_tag "$repo"
}

test_missing_signingkey_fails() {
	repo=$(make_repo missing-signingkey "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
" no)
	if run_script "$repo" 1.0.0 >/dev/null 2>&1; then
		return 1
	fi
	repo_has_no_recorded_tag "$repo"
}

test_missing_version_argument_fails() {
	repo=$(make_repo missing-version-argument "# Changelog

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

## [0.9.0] - 12026-06-20
- Older note
")
	if run_script "$repo" >/dev/null 2>&1; then
		return 1
	fi
	repo_has_no_recorded_tag "$repo"
}

test_empty_section_fails() {
	repo=$(make_repo empty-section "# Changelog

## [2.0.0] - 12026-06-27

## [1.9.9] - 12026-06-20
- Older note
")
	if run_script "$repo" 2.0.0 >/dev/null 2>&1; then
		return 1
	fi
	repo_has_no_recorded_tag "$repo"
}

test_excludes_changelog_link_references() {
	repo=$(make_repo excludes-link-refs "# Changelog

## [Unreleased]

## [1.0.0] - 12026-06-27
- Added alpha
- Added beta

[unreleased]: https://example.invalid/compare/v1.0.0...HEAD
[1.0.0]: https://example.invalid/releases/tag/v1.0.0
")
	run_script_with_input "$repo" 'y
' '' 1.0.0 >/dev/null 2>&1 || return 1
	repo_recorded_message_has "$repo" '- Added alpha' &&
		repo_recorded_message_has "$repo" '- Added beta' &&
		repo_recorded_message_lacks "$repo" '[unreleased]:' &&
		repo_recorded_message_lacks "$repo" '[1.0.0]:'
}

main() {
	check_success 'normalizes 1.0.0 to v1.0.0' test_normalizes_plain_version_to_v_tag
	check_success 'preserves v1.0.0 tag name' test_preserves_prefixed_version
	check_success 'annotation stops before next heading' test_extracts_annotation_body_until_next_heading
	check_success 'answers y to create the tag' test_accepts_yes_to_create_tag
	check_success 'answers n to abort without creating the tag' test_rejects_no_without_creating_tag
	check_success 'editor flow appends edited annotation before tagging' test_opens_editor_and_uses_edited_annotation
	check_success 'missing editor fails in edit flow' test_editor_missing_fails
	check_success 'invalid input then y still creates the tag' test_invalid_input_then_yes_creates_tag
	check_failure 'existing tag blocks creation' test_existing_tag_fails_before_creating_tag
	check_failure 'missing changelog section fails' test_missing_section_fails
	check_failure 'missing user.signingkey fails' test_missing_signingkey_fails
	check_failure 'missing version argument fails' test_missing_version_argument_fails
	check_failure 'empty section body fails' test_empty_section_fails
	check_success 'excludes changelog link references' test_excludes_changelog_link_references

	echo "summary: $PASS_COUNT passed, $FAIL_COUNT failed"
	[ "$FAIL_COUNT" -eq 0 ]
}

main "$@"

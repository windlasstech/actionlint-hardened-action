#!/bin/sh
set -eu

normalize_bool() {
	name=$1
	value=$2

	case "$value" in
		[Tt][Rr][Uu][Ee])
			printf '%s\n' true
			;;
		[Ff][Aa][Ll][Ss][Ee])
			printf '%s\n' false
			;;
		*)
			printf 'error: input %s must be true or false, got %s\n' "$name" "$value" >&2
			exit 2
			;;
	esac
}

has_glob() {
	case "$1" in
		*'*'* | *'?'* | *'['*)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

input_paths=${INPUT_PATHS:-}
input_config_file=$(printenv 'INPUT_CONFIG-FILE' 2>/dev/null || printf '%s' "${INPUT_CONFIG_FILE:-}")
input_ignore=${INPUT_IGNORE:-}
input_shellcheck=${INPUT_SHELLCHECK-shellcheck}
input_pyflakes=${INPUT_PYFLAKES-pyflakes}
input_format=${INPUT_FORMAT:-}
input_no_color=$(printenv 'INPUT_NO-COLOR' 2>/dev/null || printf '%s' "${INPUT_NO_COLOR:-true}")
input_oneline=${INPUT_ONELINE:-false}

no_color=$(normalize_bool no-color "$input_no_color")
oneline=$(normalize_bool oneline "$input_oneline")
cr=$(printf '\r')
tmp_dir=${RUNNER_TEMP:-/tmp}/actionlint-action.$$

mkdir "$tmp_dir"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM
printf '%s\n' "$input_ignore" >"$tmp_dir/ignore"
printf '%s\n' "$input_paths" >"$tmp_dir/paths"

set --

if [ -n "$input_config_file" ]; then
	set -- "$@" -config-file "$input_config_file"
fi

while IFS= read -r line || [ -n "$line" ]; do
	line=${line%"$cr"}
	if [ -n "$line" ]; then
		set -- "$@" -ignore "$line"
	fi
done <"$tmp_dir/ignore"

set -- "$@" "-shellcheck=$input_shellcheck"
set -- "$@" "-pyflakes=$input_pyflakes"

if [ -n "$input_format" ]; then
	set -- "$@" -format "$input_format"
fi

if [ "$no_color" = true ]; then
	set -- "$@" -no-color
fi

if [ "$oneline" = true ]; then
	set -- "$@" -oneline
fi

set -- "$@" --

while IFS= read -r line || [ -n "$line" ]; do
	line=${line%"$cr"}
	if [ -n "$line" ]; then
		path_matches="$tmp_dir/path-matches"
		: >"$path_matches"

		if [ -d "$line" ]; then
			find "$line" -type f \( \
				-path "$line/*.yml" -o \
				-path "$line/*.yaml" -o \
				-path '*/.github/workflows/*.yml' -o \
				-path '*/.github/workflows/*.yaml' \
			\) | sort >"$path_matches"
		elif has_glob "$line"; then
			find . -type f \( -path "./$line" -o -path "$line" \) | sort >"$path_matches"
		fi

		if [ -s "$path_matches" ]; then
			while IFS= read -r match || [ -n "$match" ]; do
				match=${match#./}
				set -- "$@" "$match"
			done <"$path_matches"
		else
			set -- "$@" "$line"
		fi
	fi
done <"$tmp_dir/paths"

exec actionlint "$@"

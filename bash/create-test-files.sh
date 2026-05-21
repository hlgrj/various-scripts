#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") --count <n> --size <size> [options]"
    echo ""
    echo "Required:"
    echo "  --count       Number of files to create"
    echo "  --size        Size of each file (e.g. 1024, 1k, 1M)"
    echo ""
    echo "Options:"
    echo "  --prefix      Filename prefix (default: 'testfile_')"
    echo "  --suffix      File extension without dot (e.g. 'txt', 'bin') — omit for no extension"
    echo "  --content     Content type: 'pattern' (default) or 'random'"
    echo "                  pattern  repeating 0-9 a-z sequence"
    echo "                  random   random bytes from /dev/urandom"
    echo "  --output-dir  Directory to create files in (default: current directory)"
    echo "  --help        Show this help message"
}

parse_size() {
    local raw="$1"
    local num unit

    if [[ "$raw" =~ ^([0-9]+)([kKmM]?)$ ]]; then
        num="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"
    else
        echo "Error: invalid size '$raw'" >&2
        exit 1
    fi

    case "$unit" in
        k|K) echo $(( num * 1024 )) ;;
        m|M) echo $(( num * 1024 * 1024 )) ;;
        *)   echo "$num" ;;
    esac
}

count=""
size_raw=""
prefix="testfile_"
suffix=""
content="pattern"
output_dir="."

while [[ $# -gt 0 ]]; do
    case "$1" in
        --count)      count="$2";      shift 2 ;;
        --size)       size_raw="$2";   shift 2 ;;
        --prefix)     prefix="$2";     shift 2 ;;
        --suffix)     suffix="$2";     shift 2 ;;
        --content)    content="$2";    shift 2 ;;
        --output-dir) output_dir="$2"; shift 2 ;;
        --help)       usage; exit 0 ;;
        *) echo "Error: unknown option '$1'" >&2; echo "" >&2; usage >&2; exit 1 ;;
    esac
done

[[ -z "$count" ]]    && { echo "Error: --count is required" >&2; echo "" >&2; usage >&2; exit 1; }
[[ -z "$size_raw" ]] && { echo "Error: --size is required" >&2; echo "" >&2; usage >&2; exit 1; }

if ! [[ "$count" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: --count must be a positive integer" >&2
    exit 1
fi

if [[ "$content" != "pattern" && "$content" != "random" ]]; then
    echo "Error: --content must be 'pattern' or 'random'" >&2
    exit 1
fi

size_bytes=$(parse_size "$size_raw")

mkdir -p "$output_dir"

digits=${#count}
created=0

for (( i = 1; i <= count; i++ )); do
    filename="$(printf "%s%0${digits}d" "$prefix" "$i")${suffix:+.$suffix}"
    filepath="$output_dir/$filename"

    if [[ "$content" == "random" ]]; then
        dd if=/dev/urandom of="$filepath" bs="$size_bytes" count=1 2>/dev/null
    else
        ( set +o pipefail; yes "0123456789abcdefghijklmnopqrstuvwxyz" | tr -d '\n' | head -c "$size_bytes" ) > "$filepath"
    fi

    (( created++ ))
    printf "\r  Created %d / %d files" "$created" "$count"
done

echo ""
echo "Done: $count file(s) of ${size_raw} ($content) created in '$output_dir'"

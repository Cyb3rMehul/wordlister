#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'


TEMP_NEW=""
TEMP_MERGED=""
cleanup() {
    local exit_code=$?
    rm -f "${TEMP_NEW:-}" "${TEMP_MERGED:-}"
    exit "$exit_code"
}
trap cleanup EXIT INT TERM


log() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" >&2
}


for cmd in grep tr sed sort wc mktemp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "ERROR" "Required dependency '$cmd' is not installed."
        exit 1
    fi
done


if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <input_file> [output_file]"
    echo "Example: $0 source.js wordlist.txt"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-filtered_words.txt}"


if [[ ! -f "$INPUT_FILE" ]] || [[ ! -r "$INPUT_FILE" ]]; then
    log "ERROR" "Input file '$INPUT_FILE' does not exist or is unreadable."
    exit 1
fi

log "INFO" "Processing source file: '$INPUT_FILE'"


TEMP_NEW=$(mktemp)
TEMP_MERGED=$(mktemp)


if ! grep -oE '[a-zA-Z0-9_\-\.]+(=|:|==)' "$INPUT_FILE" 2>/dev/null | \
     tr '&?=:;,"\\' '\n' | \
     grep -oE '[a-zA-Z0-9_\-\.]+' | \
     sed -e 's/^[._-]//g' -e 's/[._-]$//g' | \
     grep -vE '^[0-9]+$' | \
     grep -E '^[a-zA-Z_][a-zA-Z0-9_\-]{1,29}$' | \
     tr -d '\\' | \
     sort -u > "$TEMP_NEW"; then
    log "ERROR" "words extraction pipeline failed."
    exit 1
fi

NEW_COUNT=$(wc -l < "$TEMP_NEW")
if [[ "$NEW_COUNT" -eq 0 ]]; then
    log "WARN" "No valid words extracted from '$INPUT_FILE'. Output file left unchanged."
    exit 0
fi

log "INFO" "Extracted $NEW_COUNT unique candidate(s) from input."


if [[ -f "$OUTPUT_FILE" ]]; then
    if ! sort -u "$OUTPUT_FILE" "$TEMP_NEW" > "$TEMP_MERGED"; then
        log "ERROR" "Failed to merge with existing output file."
        exit 1
    fi
    mv "$TEMP_MERGED" "$OUTPUT_FILE"
else
    mv "$TEMP_NEW" "$OUTPUT_FILE"
fi

TOTAL_WORDS=$(wc -l < "$OUTPUT_FILE")

log "INFO" "Wordlist successfully updated: $OUTPUT_FILE"
log "INFO" "Total unique words in master list: $TOTAL_WORDS"

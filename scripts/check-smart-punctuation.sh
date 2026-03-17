#!/usr/bin/env bash
set -euo pipefail

CONTENT_PATH="${1:?Usage: check-smart-punctuation.sh <content-path>}"
PATTERN=$(printf '[–—\xe2\x80\x98\xe2\x80\x99\xe2\x80\x9c\xe2\x80\x9d\xe2\x80\xa6]')
FOUND=false

while IFS= read -r file; do
  BODY=$(awk 'BEGIN{i=0;f=0} /^---$/{i++;if(i==2)f=1;next} f{print}' "$file")
  if echo "$BODY" | grep -n "$PATTERN"; then
    echo "::error::Found hardcoded smart punctuation in $file"
    FOUND=true
  fi
done < <(find "$CONTENT_PATH" -name "*.md" -type f)

if [ "$FOUND" = true ]; then exit 1; fi

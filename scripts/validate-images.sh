#!/usr/bin/env bash
set -euo pipefail

VIOLATIONS=0
for file in $(find content/ -type f -name "*.md"); do
  if grep -Pn '!\[\]\([^)]+\)' "$file"; then
    echo "::error file=$file::Image missing alt text"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

if [ $VIOLATIONS -gt 0 ]; then exit 1; fi

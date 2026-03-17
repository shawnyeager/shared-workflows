#!/usr/bin/env bash
set -euo pipefail

CONTENT_PATH="${1:?Usage: validate-frontmatter.sh <content-path> [require-description]}"
REQUIRE_DESC="${2:-false}"
ERRORS=0

while IFS= read -r -d '' file; do
  [[ "$file" == *"_index.md" ]] && continue
  FRONTMATTER=$(awk '/^---$/{i++}i==1' "$file" | sed '1d;$d')

  if ! echo "$FRONTMATTER" | grep -q "^title:"; then
    echo "::error file=$file::Missing title"
    ERRORS=$((ERRORS + 1))
  fi
  if ! echo "$FRONTMATTER" | grep -q "^date:"; then
    echo "::error file=$file::Missing date"
    ERRORS=$((ERRORS + 1))
  fi
  if [[ "$REQUIRE_DESC" == "true" ]] && ! echo "$FRONTMATTER" | grep -q "^description:"; then
    echo "::error file=$file::Missing description"
    ERRORS=$((ERRORS + 1))
  fi
done < <(find "$CONTENT_PATH" -name "*.md" -type f -print0 2>/dev/null)

if [ $ERRORS -gt 0 ]; then
  echo "::error::Validation failed with $ERRORS errors"
  exit 1
fi

#!/usr/bin/env bash
set -euo pipefail

ERRORS=0

while IFS= read -r -d '' file; do
  while IFS= read -r url; do
    [ -z "$url" ] && continue
    [[ "$url" =~ ^https?:// ]] && continue

    if [[ ! "$url" =~ ^/ ]]; then
      echo "::error file=$file::Relative shortcode URL '$url' - use absolute path starting with /"
      ERRORS=$((ERRORS + 1))
      continue
    fi

    path="${url#/}"
    path="${path%/}"

    [ -f "content/${path}.md" ] && continue
    [ -f "content/${path}/_index.md" ] && continue
    [ -f "content/${path}" ] && continue
    [ -f "static/${path}" ] && continue
    [ -f "static/_redirects" ] && grep -q "^${url}[[:space:]]" "static/_redirects" && continue

    echo "::error file=$file::Shortcode URL '$url' not found in content, static, or redirects"
    ERRORS=$((ERRORS + 1))
  done < <(grep -oP 'url="\K[^"]+' "$file" 2>/dev/null || true)
done < <(find content -name "*.md" -type f -print0 2>/dev/null)

if [ $ERRORS -gt 0 ]; then
  echo "::error::Shortcode URL validation failed with $ERRORS errors"
  exit 1
fi

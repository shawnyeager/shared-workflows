#!/usr/bin/env bash
set -euo pipefail

ERRORS=0

redirect_exists() {
  local url="$1"
  if [ -f static/_redirects ] && grep -q "^${url}[[:space:]]" static/_redirects; then
    return 0
  fi
  if [ -f vercel.json ]; then
    if python3 -c '
import json, sys
url = sys.argv[1]
data = json.load(open("vercel.json"))
candidates = {url, url.rstrip("/") or "/"}
if not url.endswith("/"):
    candidates.add(url + "/")
for redirect in data.get("redirects") or []:
    source = redirect.get("source") or ""
    if source in candidates or (source.rstrip("/") or "/") in candidates:
        sys.exit(0)
sys.exit(1)
' "$url"; then
      return 0
    fi
  fi
  return 1
}

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
    redirect_exists "$url" && continue

    echo "::error file=$file::Shortcode URL '$url' not found in content, static, or redirects"
    ERRORS=$((ERRORS + 1))
  done < <(grep -oP 'url="\K[^"]+' "$file" 2>/dev/null || true)
done < <(find content -name "*.md" -type f -print0 2>/dev/null)

if [ $ERRORS -gt 0 ]; then
  echo "::error::Shortcode URL validation failed with $ERRORS errors"
  exit 1
fi

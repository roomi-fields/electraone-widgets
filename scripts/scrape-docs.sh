#!/usr/bin/env bash
# Scrape the official Electra One documentation (docs.electra.one) to a
# local mirror under .electra-docs/. The site is VitePress server-rendered
# so plain curl returns the actual HTML — no headless browser needed.
#
# Run from the repo root. Re-running is idempotent — already-downloaded
# pages are skipped.
set -euo pipefail

ROOT=".electra-docs"
mkdir -p "$ROOT"/{html,md}

# Seed list — pages we know exist. The BFS step below discovers the rest
# by parsing internal hrefs from each page.
SEEDS=(
  "/"
  "/developers/luaext.html"
  "/developers/presetformat.html"
  "/developers/midiimplementation.html"
  "/developers/instrumentformat.html"
  "/developers/confformat.html"
  "/developers/devicesformat.html"
  "/developers/performanceformat.html"
  "/developers/filetransfer.html"
  "/userguide/quickstart.html"
  "/userguide/editor.html"
  "/userguide/firstpreset.html"
  "/luacourse/index.html"
  "/troubleshooting/index.html"
  "/downloads/firmware.html"
  "/downloads/updatemkII.html"
)

declare -A SEEN
QUEUE=("${SEEDS[@]}")
DISCOVERED=()

while [ ${#QUEUE[@]} -gt 0 ]; do
  url="${QUEUE[0]}"
  QUEUE=("${QUEUE[@]:1}")
  [ -n "${SEEN[$url]:-}" ] && continue
  SEEN[$url]=1
  DISCOVERED+=("$url")
  content=$(curl -sS "https://docs.electra.one${url}" 2>/dev/null) || continue
  [ -z "$content" ] && continue
  while IFS= read -r link; do
    clean=$(echo "$link" | sed 's/[?#].*//')
    if [[ "$clean" == /* ]] && [[ "$clean" == *.html ]] && [ -z "${SEEN[$clean]:-}" ]; then
      QUEUE+=("$clean")
    fi
  done < <(echo "$content" | grep -oE 'href="[^"]*\.html[^"]*"' | sed 's/href="//; s/".*$//')
done

echo "Discovered ${#DISCOVERED[@]} pages"

for url in "${DISCOVERED[@]}"; do
  path="${url#/}"
  [ -z "$path" ] && path="index.html"
  out_html="$ROOT/html/$path"
  out_md="$ROOT/md/${path%.html}.md"
  mkdir -p "$(dirname "$out_html")" "$(dirname "$out_md")"
  if [ -s "$out_html" ] && [ -s "$out_md" ]; then continue; fi
  curl -sS "https://docs.electra.one${url}" -o "$out_html"
  # Extract <main>…</main>, strip script/style, then html2text
  python3 -c "
import re, sys
html = open('$out_html').read()
m = re.search(r'<main[^>]*>(.*?)</main>', html, re.DOTALL)
body = m.group(1) if m else html
body = re.sub(r'<script[^>]*>.*?</script>', '', body, flags=re.DOTALL)
body = re.sub(r'<style[^>]*>.*?</style>', '', body, flags=re.DOTALL)
sys.stdout.write(body)
" | html2text -nobs -utf8 > "$out_md" 2>/dev/null || true
done

echo "Wrote markdown to $ROOT/md/ ($(find "$ROOT/md" -name '*.md' | wc -l) files)"

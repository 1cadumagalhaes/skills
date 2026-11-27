#!/usr/bin/env bash
# What is a site's animation actually made of?
#
#   ./fingerprint.sh https://example.com
#
# Reads the HTML it serves and counts the signatures of the techniques that
# produce the look: a library doing it, or hand-written canvas / SVG / CSS.
# The script names are the most revealing part — a site that ships
# "ascii.js", "iso.js", "campo.js" is hand-built engine by engine.

set -uo pipefail

url="${1:?usage: fingerprint.sh <url>}"
ua='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'

html=$(curl -sL --max-time 25 -A "$ua" -w '\n%{http_code}' "$url")
code=${html##*$'\n'}
html=${html%$'\n'*}
case "$code" in
  2*) : ;;
  429) echo "rate-limited (429): wait a minute, or read the files from your own copy" >&2; exit 2 ;;
  *)   echo "fetch failed: HTTP $code — $url" >&2; exit 2 ;;
esac
bytes=$(printf %s "$html" | wc -c)
printf '\n%s\n  %s bytes of HTML\n\n' "$url" "$bytes"

printf 'files loaded\n'
printf '%s' "$html" \
  | grep -oiE '(src|href)="[^"]+\.(js|mjs|css)[^"]*"' \
  | sed -E 's/^(src|href)="//; s/"$//' \
  | sort -u | sed 's/^/  /' | head -40

printf '\nlibrary signatures\n'
found=0
while IFS='|' read -r label pattern; do
  n=$(printf '%s' "$html" | grep -oiE "$pattern" | wc -l)
  if [ "$n" -gt 0 ]; then printf '  %-14s %s\n' "$label" "$n"; found=1; fi
done <<'SIGS'
gsap|gsap[./"']
scrolltrigger|ScrollTrigger
three|three(\.min)?\.(module\.)?js
framer-motion|framer-motion
lenis|lenis
locomotive|locomotive-scroll
barba|barba
swiper|swiper
anime|anime\.min\.js
lottie|lottie
d3|d3(@[0-9]|\.min\.js|/d3)
SIGS
[ "$found" = 0 ] && printf '  none in the HTML (bundles may still hide them)\n'

printf '\ntechnique signatures\n'
while IFS='|' read -r label pattern; do
  n=$(printf '%s' "$html" | grep -oiE "$pattern" | wc -l)
  if [ "$n" -gt 0 ]; then printf '  %-22s %s\n' "$label" "$n"; fi
done <<'SIGS'
canvas|<canvas
svg-animation|<animate|<animateTransform
stroke-dash|stroke-dashoffset|stroke-dasharray
css-keyframes|@keyframes
css-scroll-timeline|animation-timeline
css-view-timeline|view\(\)|scroll\(
intersectionobserver|IntersectionObserver
raf|requestAnimationFrame
reduced-motion|prefers-reduced-motion
webgl|getContext\(['"]webgl
SIGS

printf '\nreading\n'
libs=$(printf '%s' "$html" | grep -ciE 'gsap|three(\.min)?\.(module\.)?js|framer-motion|lenis|locomotive|barba' || true)
canvas=$(printf '%s' "$html" | grep -ciE '<canvas' || true)
raf=$(printf '%s' "$html" | grep -ci 'requestAnimationFrame' || true)
kf=$(printf '%s' "$html" | grep -ci '@keyframes' || true)
if [ "$libs" -gt 0 ]; then
  printf '  a library is driving the motion; the craft is in the timeline, not the maths\n'
elif [ "$canvas" -gt 0 ] || [ "$raf" -gt 0 ]; then
  printf '  hand-written: no motion library in the HTML, but canvas/rAF are in play\n'
elif [ "$kf" -gt 0 ]; then
  printf '  CSS-first: keyframes and transitions, little or no script\n'
else
  printf '  nothing obvious in the HTML — look at the JS bundles\n'
fi
printf '\n  next: curl -s %s | grep -oE "src=\\"[^\\"]+\\.js[^\\"]*\\"" and read those files;\n' "$url"
printf '  their names usually say what they draw (and the comments say how).\n\n'

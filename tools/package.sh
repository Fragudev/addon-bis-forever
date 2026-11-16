#!/usr/bin/env bash
# Builds the distributable addon zip and verifies that it loads as shipped.
# Usage: tools/package.sh <version>   (writes Forever-<version>.zip)
set -euo pipefail

version="${1:?usage: tools/package.sh <version>}"
addon="ForeverBiS"
zipfile="Forever-${version}.zip"
build="$(mktemp -d)"
trap 'rm -rf "$build"' EXIT

fail() {
  echo "package: $*" >&2
  exit 1
}

# Stage a clean copy so the working tree is never modified.
cp -R "$addon" "$build/$addon"
find "$build" \( -name ".DS_Store" -o -name "desktop.ini" -o -name ".git*" \) -exec rm -rf {} +

toc="$build/$addon/$addon.toc"
[[ -f "$toc" ]] || fail "missing $addon.toc"

# A beta tag such as beta_0.0.35 must match the TOC version (beta-0.0.35).
if [[ "$version" == beta_* ]]; then
  expected="${version//_/-}"
  actual="$(sed -n 's/^## Version: //p' "$toc" | tr -d '\r')"
  [[ "$actual" == "$expected" ]] || fail "TOC version '$actual' does not match tag '$version' (expected '$expected')"
fi

# A stable tag such as v1.0.0 writes its version (1.0.0) into the packaged TOC only; the repository keeps the
# beta version that develop bumps.
if [[ "$version" == v* ]]; then
  [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "stable tag '$version' must look like vX.Y.Z"
  sed -i.bak "s/^## Version: .*/## Version: ${version#v}/" "$toc"
  rm -f "$toc.bak"
fi

# Every file the client loads must be present in the package.
while IFS= read -r line; do
  line="${line%$'\r'}"
  [[ -z "$line" || "$line" == \#* ]] && continue
  [[ -f "$build/$addon/${line//\\//}" ]] || fail "missing $line (referenced by $addon.toc)"
done <"$toc"

rm -f "$zipfile"
(cd "$build" && zip -qr - "$addon") >"$zipfile"
echo "package: built $zipfile ($(unzip -l "$zipfile" | tail -1 | awk '{print $2}') files)"

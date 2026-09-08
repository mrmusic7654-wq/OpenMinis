#!/usr/bin/env bash
# Stage the APK produced by `./gradlew :app:assemble<Variant>` under a
# descriptive name and make sure the sandbox runtime actually made it into the
# package before it is published as a workflow artifact.
#
# Used by .github/workflows/android.yml, but safe to run locally after a build:
#
#   ./.github/scripts/stage_apk.sh debug      # or: release
#
# Output: src/android/app/build/outputs/apk/staged/Fin-<versionName>-<variant>-<sha7>.apk
# Under GitHub Actions the path is also exported as the step output `path`
# (plus `name`), and a size/SHA-256 line is appended to the job summary.
set -euo pipefail

variant="${1:-debug}"
case "$variant" in
  debug|release) ;;
  *) echo "usage: $0 debug|release" >&2; exit 2 ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/src/android/app"
apk_dir="$app_dir/build/outputs/apk/$variant"
out_dir="$app_dir/build/outputs/apk/staged"
gradle_file="$app_dir/build.gradle.kts"

shopt -s nullglob
apks=("$apk_dir"/*.apk)
shopt -u nullglob
if [ "${#apks[@]}" -ne 1 ]; then
  echo "error: expected exactly one .apk in $apk_dir, found ${#apks[@]}" >&2
  ls -la "$apk_dir" >&2 2>/dev/null || true
  exit 1
fi
apk="${apks[0]}"

# ---------------------------------------------------------------------------
# The sandbox runtime is built by deps/build_proot.sh and
# scripts/prepare_android_sandbox.sh and is gitignored, so a tree where those
# were skipped still compiles — the app just answers every shell command with
# "[Shell not running]". Fail here instead of shipping that APK.
# ---------------------------------------------------------------------------
required=(
  lib/arm64-v8a/libproot.so
  lib/arm64-v8a/libproot-loader.so
  lib/arm64-v8a/libproot-loader32.so
  assets/proot-aarch64
)
listing="$(unzip -Z1 "$apk")"
missing=0
for entry in "${required[@]}"; do
  if ! grep -qxF -- "$entry" <<<"$listing"; then
    echo "error: $(basename "$apk") does not contain $entry" >&2
    missing=1
  fi
done
# AAPT may transparently gunzip the rootfs and package it as .tar; the app
# (RootfsManager.ROOTFS_ASSET / ROOTFS_ASSET_TAR) tries both names, so accept
# either here too.
if ! grep -qxE -- 'assets/alpine-minirootfs\.tar(\.gz)?' <<<"$listing"; then
  echo "error: $(basename "$apk") does not contain assets/alpine-minirootfs.tar.gz (or .tar)" >&2
  missing=1
fi
if [ "$missing" -ne 0 ]; then
  echo "error: the APK would ship with a broken sandbox. Run ./deps/build_proot.sh and" >&2
  echo "       ./scripts/prepare_android_sandbox.sh, then rebuild (see BUILDING.md)." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Stage under Fin-<versionName>-<variant>-<sha7>.apk
# ---------------------------------------------------------------------------
version="$(sed -nE 's/^[[:space:]]*versionName[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$gradle_file" | head -n1)"
: "${version:=unknown}"
sha="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD 2>/dev/null || echo unknown)}"
sha="${sha:0:7}"

mkdir -p "$out_dir"
staged="$out_dir/Fin-${version}-${variant}-${sha}.apk"
cp -f "$apk" "$staged"

digest="$(sha256sum "$staged" | awk '{print $1}')"
size="$(du -h "$staged" | cut -f1)"
echo "staged: $staged ($size)"
echo "sha256: $digest"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "path=$staged"
    echo "name=$(basename "$staged")"
  } >> "$GITHUB_OUTPUT"
fi
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### $(basename "$staged")"
    echo
    echo "| Size | SHA-256 |"
    echo "|---|---|"
    echo "| $size | \`$digest\` |"
    echo
  } >> "$GITHUB_STEP_SUMMARY"
fi

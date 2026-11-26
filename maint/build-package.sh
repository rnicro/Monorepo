#!/usr/bin/env bash
set -euo pipefail

# Build from the same local source tree used by the reusable GitHub workflow.
repo_root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
package="${1:-}"
void_packages="${2:-"$repo_root/../void-packages"}"
target_arch="${XBPS_TARGET_ARCH:-x86_64-musl}"

usage() {
  echo "Usage: bash maint/build-package.sh <package> [void-packages-directory]" >&2
  exit 2
}

case "$package" in
  aria2|brightnessctl|librewolf|linux7.3|tofi|velotype|wlsunset) ;;
  *) usage ;;
esac

if [[ "$target_arch" != x86_64-musl ]]; then
  echo "This package collection currently supports x86_64-musl only." >&2
  exit 1
fi
if [[ ! -x "$void_packages/xbps-src" ]]; then
  echo "Void build tree not found: $void_packages" >&2
  echo "Clone https://github.com/void-linux/void-packages.git first." >&2
  exit 1
fi
if ! command -v xbps-install >/dev/null 2>&1; then
  echo "xbps-install is required. On CI, the shared workflow adds xbps-static to PATH." >&2
  exit 1
fi

cd "$repo_root"

# Keep validation and preparation beside the package so local and CI builds agree.
bash "maint/$package/scripts/test-template.sh"

rm -rf -- "$void_packages/srcpkgs/$package"
mkdir -p -- "$void_packages/srcpkgs/$package"
cp -a -- "srcpkgs/$package/." "$void_packages/srcpkgs/$package/"

case "$package" in
  librewolf)
    # Mozilla's two fallback C files are fetched from a pinned commit and hash-checked.
    bash maint/librewolf/scripts/prepare-source-fallbacks.sh \
      "$void_packages/srcpkgs/librewolf/files"
    ;;
  velotype)
    # Cache the exact upstream commit archive under Void's source cache.
    version="$(sed -n 's/^version=//p' srcpkgs/velotype/template)"
    mkdir -p "$void_packages/hostdir/sources/velotype-$version"
    bash maint/velotype/scripts/prepare-source.sh \
      "$void_packages/hostdir/sources/velotype-$version"
    ;;
esac

# binary-bootstrap is safe to re-run; xbps-src reuses its existing bootstrap.
(
  cd "$void_packages"
  ./xbps-src -A "$target_arch" binary-bootstrap

  if [[ "$package" == librewolf ]]; then
    # Give Mozilla's build system a stable source epoch tied to the package inputs.
    epoch="$(git -C "$repo_root" log -1 --format=%ct -- \
      srcpkgs/librewolf/template srcpkgs/librewolf/files srcpkgs/librewolf/patches 2>/dev/null || true)"
    [[ "$epoch" =~ ^[0-9]+$ ]] || epoch=0
    printf '%s\n' "$epoch" > hostdir/source-date-epoch
    chmod 644 hostdir/source-date-epoch
    ./xbps-src -A "$target_arch" -o pgo pkg "$package"
  else
    ./xbps-src -A "$target_arch" pkg "$package"
  fi
)

# linux7.3 can produce both kernel and headers archives; retain every package output.
mkdir -p "$repo_root/dist"
rm -f -- "$repo_root"/dist/"$package"-*.xbps
mapfile -d '' outputs < <(
  find "$void_packages/hostdir/binpkgs" -type f -name "$package-*.xbps" -print0
)
if (( ${#outputs[@]} == 0 )); then
  echo "No XBPS package output found for $package." >&2
  find "$void_packages/hostdir/binpkgs" -type f -name '*.xbps' -print >&2
  exit 1
fi
cp -- "${outputs[@]}" "$repo_root/dist/"

printf 'Built %s for %s:\n' "$package" "$target_arch"
printf '  %s\n' "${outputs[@]##*/}"

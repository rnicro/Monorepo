#!/usr/bin/env bash
set -euo pipefail

# Exercise the shared build entry point without network access or a real compiler.
repo_root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
fake_bin="$tmp/bin"
void_packages="$tmp/void-packages"
dist_dir="$tmp/dist"
mkdir -p "$fake_bin" "$void_packages/hostdir" "$dist_dir"

cat > "$fake_bin/xbps-install" <<'XBPS_INSTALL'
#!/bin/sh
exit 0
XBPS_INSTALL
chmod +x "$fake_bin/xbps-install"

cat > "$void_packages/xbps-src" <<'XBPS_SRC'
#!/usr/bin/env bash
set -euo pipefail

case "$*" in
  "-A x86_64-musl binary-bootstrap")
    mkdir -p hostdir/binpkgs
    : > hostdir/bootstrap-complete
    ;;
  "-A x86_64-musl pkg brightnessctl")
    test -f hostdir/bootstrap-complete
    version="$(sed -n 's/^version=//p' "$XBPS_TEST_REPO_ROOT/srcpkgs/brightnessctl/template")"
    revision="$(sed -n 's/^revision=//p' "$XBPS_TEST_REPO_ROOT/srcpkgs/brightnessctl/template")"
    output="hostdir/binpkgs/brightnessctl-${version}_${revision}.x86_64-musl.xbps"
    printf '%s\n' 'mock package for brightnessctl' > "$output"
    ;;
  *)
    echo "unexpected xbps-src arguments: $*" >&2
    exit 64
    ;;
esac
XBPS_SRC
chmod +x "$void_packages/xbps-src"

export PATH="$fake_bin:$PATH"
export XBPS_TARGET_ARCH=x86_64-musl
export DIST_DIR="$dist_dir"
export XBPS_TEST_REPO_ROOT="$repo_root"

bash "$repo_root/maint/build-package.sh" brightnessctl "$void_packages"

version="$(sed -n 's/^version=//p' "$repo_root/srcpkgs/brightnessctl/template")"
revision="$(sed -n 's/^revision=//p' "$repo_root/srcpkgs/brightnessctl/template")"
package_file="$dist_dir/brightnessctl-${version}_${revision}.x86_64-musl.xbps"

[[ -s "$void_packages/srcpkgs/brightnessctl/template" ]] || {
  echo "The package recipe was not overlaid into Void's srcpkgs tree." >&2
  exit 1
}
[[ -s "$void_packages/hostdir/bootstrap-complete" ]] || {
  echo "The shared build helper did not run binary-bootstrap." >&2
  exit 1
}
[[ -s "$package_file" ]] || {
  echo "The package archive was not copied to dist/: $package_file" >&2
  find "$dist_dir" -maxdepth 1 -type f -print >&2
  exit 1
}
grep -Fq 'mock package for brightnessctl' "$package_file" || {
  echo "The copied package artifact does not contain the expected test payload." >&2
  exit 1
}

echo "shared build helper overlay/bootstrap/artifact test passed"

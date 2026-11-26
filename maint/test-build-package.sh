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
  "-A x86_64-musl pkg linux7.3")
    test -f hostdir/bootstrap-complete
    version="$(sed -n 's/^version=//p' "$XBPS_TEST_REPO_ROOT/srcpkgs/linux7.3/template")"
    revision="$(sed -n 's/^revision=//p' "$XBPS_TEST_REPO_ROOT/srcpkgs/linux7.3/template")"
    printf '%s\n' 'mock kernel package' > \
      "hostdir/binpkgs/linux7.3-${version}_${revision}.x86_64-musl.xbps"
    printf '%s\n' 'mock kernel headers package' > \
      "hostdir/binpkgs/linux7.3-headers-${version}_${revision}.x86_64-musl.xbps"
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

# A simple single-output utility validates the common overlay/build path.
bash "$repo_root/maint/build-package.sh" brightnessctl "$void_packages"
version="$(sed -n 's/^version=//p' "$repo_root/srcpkgs/brightnessctl/template")"
revision="$(sed -n 's/^revision=//p' "$repo_root/srcpkgs/brightnessctl/template")"
brightnessctl_file="$dist_dir/brightnessctl-${version}_${revision}.x86_64-musl.xbps"
[[ -s "$void_packages/srcpkgs/brightnessctl/template" ]]
[[ -f "$void_packages/hostdir/bootstrap-complete" ]]
[[ -s "$brightnessctl_file" ]]
grep -Fq 'mock package for brightnessctl' "$brightnessctl_file"

# The kernel recipe emits two versioned packages; both must reach the artifact directory.
bash "$repo_root/maint/build-package.sh" linux7.3 "$void_packages"
version="$(sed -n 's/^version=//p' "$repo_root/srcpkgs/linux7.3/template")"
revision="$(sed -n 's/^revision=//p' "$repo_root/srcpkgs/linux7.3/template")"
kernel_file="$dist_dir/linux7.3-${version}_${revision}.x86_64-musl.xbps"
headers_file="$dist_dir/linux7.3-headers-${version}_${revision}.x86_64-musl.xbps"
[[ -s "$kernel_file" ]]
[[ -s "$headers_file" ]]
grep -Fq 'mock kernel package' "$kernel_file"
grep -Fq 'mock kernel headers package' "$headers_file"

echo "shared build helper overlay/bootstrap/artifact tests passed"

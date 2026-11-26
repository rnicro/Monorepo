#!/bin/sh
set -eu

template="srcpkgs/niri/template"
guide="srcpkgs/niri/README.niri.md"
[ -s "$template" ] || { echo "Missing niri template" >&2; exit 1; }
[ -s "$guide" ] || { echo "Missing niri package guide" >&2; exit 1; }

grep -Eq '^pkgname=niri$' "$template"
grep -Eq '^version=26\.04$' "$template"
grep -Eq '^revision=[0-9]+$' "$template"
grep -Fq 'build_style=cargo' "$template"
grep -Fq -- '--no-default-features --features dbus,xdp-gnome-screencast' "$template"
grep -Fq 'clang19-devel' "$template"
grep -Fq 'archs="x86_64-musl"' "$template"
grep -Fq 'if [ "$XBPS_TARGET_LIBC" != musl ]' "$template"
grep -Fq 'vtargetrun "${DESTDIR}/usr/bin/niri" completions' "$template"
grep -Fq 'systemd feature' "$guide"

checksum="$(sed -n 's/^checksum=//p' "$template")"
[ "${#checksum}" -eq 64 ] || {
    echo "Expected a 64-character source SHA-256 checksum." >&2
    exit 1
}
case "$checksum" in
    *[!0-9a-f]*)
        echo "niri checksum must be lowercase hexadecimal." >&2
        exit 1
        ;;
esac

echo "niri Cargo release, feature selection and musl test checks passed"

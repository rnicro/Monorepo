#!/bin/sh
set -eu

template="srcpkgs/labwc/template"
guide="srcpkgs/labwc/README.labwc.md"
[ -s "$template" ] || { echo "Missing labwc template" >&2; exit 1; }
[ -s "$guide" ] || { echo "Missing labwc package guide" >&2; exit 1; }

grep -Eq '^pkgname=labwc$' "$template"
grep -Eq '^version=0\.20\.3$' "$template"
grep -Eq '^revision=[0-9]+$' "$template"
grep -Fq 'build_style=meson' "$template"
grep -Fq 'wlroots0.20-devel' "$template"
grep -Fq 'xorg-server-xwayland' "$template"
grep -Fq -- '-Dsystemd-session=disabled' "$template"
grep -Fq 'archs="x86_64-musl"' "$template"

checksum="$(sed -n 's/^checksum=//p' "$template")"
[ "${#checksum}" -eq 64 ] || {
    echo "Expected a 64-character source SHA-256 checksum." >&2
    exit 1
}
case "$checksum" in
    *[!0-9a-f]*)
        echo "labwc checksum must be lowercase hexadecimal." >&2
        exit 1
        ;;
esac

echo "labwc release, wlroots ABI and musl session checks passed"

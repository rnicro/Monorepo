#!/bin/sh
set -eu

template="srcpkgs/noctalia/template"
guide="srcpkgs/noctalia/README.noctalia.md"
[ -s "$template" ] || { echo "Missing Noctalia template" >&2; exit 1; }
[ -s "$guide" ] || { echo "Missing Noctalia package guide" >&2; exit 1; }

grep -Eq '^pkgname=noctalia$' "$template"
grep -Eq '^version=5\.6\.0$' "$template"
grep -Eq '^revision=[0-9]+$' "$template"
grep -Fq 'wrksrc=noctalia-release' "$template"
grep -Fq 'build_style=meson' "$template"
grep -Fq -- '-Dtests=disabled' "$template"
grep -Fq -- '-Djemalloc=disabled' "$template"
grep -Fq 'archs="x86_64-musl"' "$template"
grep -Fq 'noctalia-v${version}.tar.gz' "$template"
grep -Fq 'vtargetrun "${DESTDIR}/usr/bin/noctalia" completions' "$template"
grep -Fq 'noctalia-pam-helper' "$guide"
grep -Fq 'PipeWire and WirePlumber' "$guide"

checksum="$(sed -n 's/^checksum=//p' "$template")"
[ "${#checksum}" -eq 64 ] || {
    echo "Expected the official release archive SHA-256." >&2
    exit 1
}
case "$checksum" in
    *[!0-9a-f]*)
        echo "Noctalia checksum must be lowercase hexadecimal." >&2
        exit 1
        ;;
esac

echo "Noctalia release, musl options, assets and completion checks passed"

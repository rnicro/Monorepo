#!/bin/sh
set -eu

template="srcpkgs/umbriel/template"
guide="srcpkgs/umbriel/README.umbriel.md"
[ -s "$template" ] || { echo "Missing Umbriel template" >&2; exit 1; }
[ -s "$guide" ] || { echo "Missing Umbriel package guide" >&2; exit 1; }

grep -Eq '^pkgname=umbriel$' "$template"
grep -Eq '^version=0\.1\.0$' "$template"
grep -Eq '^revision=[0-9]+$' "$template"
grep -Eq '^_commit=[0-9a-f]{40}$' "$template"
grep -Fq 'wrksrc="${pkgname}-${_commit}"' "$template"
grep -Fq 'distfiles="${homepage}/archive/${_commit}.tar.gz"' "$template"
grep -Fxq 'checksum=SKIP' "$template"
grep -Fq 'wlroots0.20-devel' "$template"
grep -Fq 'libei-devel' "$template"
grep -Fq -- '-Djemalloc=disabled' "$template"
grep -Fq -- '-Dlocaled=disabled' "$template"
grep -Fq 'archs="x86_64-musl"' "$template"
grep -Fq 'verification is skipped for this one archive.' "$guide"

echo "Umbriel immutable source pin, wlroots ABI and musl options checks passed"

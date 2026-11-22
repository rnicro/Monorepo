#!/usr/bin/env bash
set -euo pipefail

template="${1:-srcpkgs/linux7.3/template}"
[ -s "$template" ] || { echo "Missing package template: $template" >&2; exit 1; }
bash -n "$template"

pkgname="$(sed -n 's/^pkgname=//p' "$template")"
version="$(sed -n 's/^version=//p' "$template")"
revision="$(sed -n 's/^revision=//p' "$template")"
[[ "$pkgname" == linux7.3 ]]
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
[[ "$revision" =~ ^[1-9][0-9]*$ ]]
grep -Fq 'archs="x86_64-musl"' "$template"
grep -Fq 'dotconfig-custom' "$template"
[ -s srcpkgs/linux7.3/files/x86_64-dotconfig-custom ]
grep -Fq 'validate-config.sh' "$template"

sh srcpkgs/linux7.3/files/validate-config.sh srcpkgs/linux7.3/files/x86_64-dotconfig-custom
echo "linux7.3 x86_64-musl template and kernel configuration checks passed"

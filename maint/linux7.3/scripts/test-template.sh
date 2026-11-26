#!/usr/bin/env bash
set -euo pipefail

template="${1:-srcpkgs/linux7.3/template}"
[ -s "$template" ] || { echo "Missing package template: $template" >&2; exit 1; }
bash -n "$template"

pkgname="$(sed -n 's/^pkgname=//p' "$template")"
version="$(sed -n 's/^version=//p' "$template")"
revision="$(sed -n 's/^revision=//p' "$template")"
[[ "$pkgname" == linux7.3 ]]
[[ "$version" == 7.3.6 ]]
[[ "$revision" =~ ^[1-9][0-9]*$ ]]
grep -Fq 'archs="x86_64-musl"' "$template"
grep -Fq 'dotconfig-custom' "$template"
[ -s srcpkgs/linux7.3/files/x86_64-dotconfig-custom ]
grep -Fq 'validate-config.sh' "$template"

checksums="$(sed -n '/^checksum="/,/"/p' "$template" | grep -Eo '[0-9a-f]{64}')"
[[ "$(printf '%s\n' "$checksums" | wc -l)" -eq 2 ]]
grep -Fq '87363c24f10e06321eb362765521094e94471f6bff8bce2d6b3e40f39f004953' <<< "$checksums"
grep -Fq '11f630161b995ae31bbf79e9056e22b291bd47a389c9ad542091b4f342616718' <<< "$checksums"

sh srcpkgs/linux7.3/files/validate-config.sh srcpkgs/linux7.3/files/x86_64-dotconfig-custom
echo "linux7.3 x86_64-musl template and kernel configuration checks passed"

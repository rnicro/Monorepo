#!/usr/bin/env bash
set -euo pipefail

template="${1:-srcpkgs/velotype/template}"
[ -s "$template" ] || { echo "Missing package template: $template" >&2; exit 1; }
bash -n "$template"

pkgname="$(sed -n 's/^pkgname=//p' "$template")"
version="$(sed -n 's/^version=//p' "$template")"
revision="$(sed -n 's/^revision=//p' "$template")"
commit="$(sed -n 's/^_commit=//p' "$template")"
checksum="$(sed -n 's/^checksum=//p' "$template")"

[[ "$pkgname" == velotype ]]
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
[[ "$revision" =~ ^[1-9][0-9]*$ ]]
[[ "$commit" =~ ^[0-9a-f]{40}$ ]]
[[ "$checksum" =~ ^[0-9a-f]{64}$ ]]

grep -Fq 'build_style=cargo' "$template"
grep -Fq 'wayland-devel' "$template"
grep -Fq 'wayland-protocols' "$template"
grep -Fq 'x86_64-musl) ;;' "$template"
grep -Fq 'broken="only supported on x86_64-musl / Intel Skylake"' "$template"
grep -Fq 'target-cpu=skylake' "$template"
grep -Fq 'RUSTC_WRAPPER=sccache' "$template"
grep -Fq 'gpui_platform = { package = "gpui-pre-platform"' "$template"

echo "velotype x86_64-musl / Wayland / Skylake template checks passed"

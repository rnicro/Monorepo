#!/usr/bin/env bash
set -euo pipefail

# The fallback files are upstream Mozilla sources, not files from a sibling rnicro repo.
repo_root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../" && pwd)"
files_dir="${1:-$repo_root/srcpkgs/librewolf/files}"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/librewolf-source-fallbacks.XXXXXX")"
trap 'rm -rf -- "$tmp_dir"' EXIT
mkdir -p "$files_dir"

fetch_verify_install() {
  local filename="$1"
  local url="$2"
  local expected_sha256="$3"
  local tmp="$tmp_dir/$filename"

  curl --fail --location --retry 5 --retry-all-errors \
    --connect-timeout 30 --max-time 300 \
    --output "$tmp" "$url"

  printf '%s  %s\n' "$expected_sha256" "$tmp" | sha256sum --check --status || {
    echo "Mozilla config/$filename failed SHA-256 verification." >&2
    exit 1
  }

  install -m 644 -- "$tmp" "$files_dir/$filename"
  echo "Prepared verified Mozilla config/$filename."
}

# Update the commit and both digests together when refreshing these source fallbacks.
mozilla_commit=45030f6970cae629c797527ce66836dcad7804d4
fetch_verify_install \
  nsinstall.c \
  "https://raw.githubusercontent.com/mozilla/gecko-dev/$mozilla_commit/config/nsinstall.c" \
  "f245dab3eeaa6f98d612eee01aa1fd2b6848e94186ab1d97c6b69e6811966611"
fetch_verify_install \
  pathsub.c \
  "https://raw.githubusercontent.com/mozilla/gecko-dev/$mozilla_commit/config/pathsub.c" \
  "a9a772f937ab63cbaf9c01fa62204e4e455aa414709bd047ccd00f1701f6b95a"

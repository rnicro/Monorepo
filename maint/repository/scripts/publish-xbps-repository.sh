#!/usr/bin/env bash
set -euo pipefail

incoming_dir=${1:?usage: publish-xbps-repository.sh INCOMING_DIR}
: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GH_REPO:?GH_REPO is required}"
: "${PRIV_KEY:?PRIV_KEY secret is required}"
: "${SIGN_PASS:?SIGN_PASS secret is required}"
: "${SIGNEDBY:?SIGNEDBY repository variable is required}"
: "${XBPS_TARGET_ARCH:?XBPS_TARGET_ARCH is required}"

repository_tag=${REPOSITORY_TAG:-xbps-repository}
work_root="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/rnicro-xbps-repo.XXXXXX")"
repository_dir="${work_root}/repository"
key_file="${work_root}/private.pem"
mkdir -p "$repository_dir"
cleanup() {
  rm -f -- "$key_file"
  rm -rf -- "$work_root"
}
trap cleanup EXIT

command -v gh >/dev/null 2>&1 || { echo "GitHub CLI (gh) is required." >&2; exit 1; }
command -v xbps-rindex >/dev/null 2>&1 || { echo "xbps-rindex is required." >&2; exit 1; }

shopt -s nullglob
incoming_packages=("$incoming_dir"/*.xbps)
if (( ${#incoming_packages[@]} == 0 )); then
  echo "No XBPS packages were provided in $incoming_dir." >&2
  exit 1
fi
for package in "${incoming_packages[@]}"; do
  [[ -s "$package" ]] || { echo "Package is missing or empty: $package" >&2; exit 1; }
done

release_exists=false
if gh release view "$repository_tag" --repo "$GH_REPO" >/dev/null 2>&1; then
  release_exists=true
  gh release download "$repository_tag" --repo "$GH_REPO" --dir "$repository_dir"
fi

for package in "${incoming_packages[@]}"; do
  destination="${repository_dir}/$(basename "$package")"
  if [[ -e "$destination" ]]; then
    if ! cmp -s -- "$package" "$destination"; then
      echo "Refusing to replace published package bytes: $(basename "$package")" >&2
      echo "Increment revision in the package template before publishing changed output." >&2
      exit 1
    fi
  else
    install -m 0644 -- "$package" "$destination"
  fi
done

packages=("$repository_dir"/*.xbps)
if (( ${#packages[@]} == 0 )); then
  echo "The repository contains no XBPS packages." >&2
  exit 1
fi

repodata_file="${repository_dir}/${XBPS_TARGET_ARCH}-repodata"
repository_initialized=false
[[ -s "$repodata_file" ]] && repository_initialized=true

# Register the current package versions, then discard package files no longer
# referenced by the index. This keeps the release a compact, usable XBPS repo.
xbps-rindex -a "${packages[@]}"
xbps-rindex --remove-obsoletes "$repository_dir"
xbps-rindex --clean "$repository_dir"

# A fresh repository needs its signing identity embedded once. Existing releases
# carry the same repodata forward, preserving the original trusted public key.
if [[ "$repository_initialized" != true ]]; then
  xbps-rindex --privkey "$key_file" --sign --signedby "$SIGNEDBY" "$repository_dir"
fi

# Existing valid signatures are retained; newly added package archives are signed.
packages=("$repository_dir"/*.xbps)
xbps-rindex --privkey "$key_file" --sign-pkg "${packages[@]}"

[[ -s "$repodata_file" ]] || {
  echo "Expected repository index was not generated: $repodata_file" >&2
  exit 1
}
for package in "${packages[@]}"; do
  [[ -s "${package}.sig2" ]] || {
    echo "Missing XBPS package signature: ${package}.sig2" >&2
    exit 1
  }
done

(
  cd "$repository_dir"
  sha256sum -- *.xbps *.xbps.sig2 "${XBPS_TARGET_ARCH}-repodata" > SHA256SUMS
)

assets=("${packages[@]}" "$repository_dir"/*.xbps.sig2 "$repodata_file" "$repository_dir/SHA256SUMS")
export XBPS_PASSPHRASE="$SIGN_PASS"
unset PRIV_KEY SIGN_PASS

if [[ "$release_exists" == true ]]; then
  gh release upload "$repository_tag" "${assets[@]}" --repo "$GH_REPO" --clobber
else
  gh release create "$repository_tag" "${assets[@]}" --repo "$GH_REPO" \
    --title "rnicro XBPS repository" \
    --notes "Signed XBPS repository for x86_64-musl. Configure XBPS with the repository URL in the rnicro Monorepo README."
fi

printf 'Published signed XBPS repository: %s/releases/download/%s\n' \
  "https://github.com/$GH_REPO" "$repository_tag"

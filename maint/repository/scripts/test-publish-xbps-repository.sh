#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
fake_bin="$tmp/bin"
state="$tmp/state"
incoming="$tmp/incoming"
mkdir -p "$fake_bin" "$state/assets" "$incoming"
export GH_STATE="$state" GH_LOG="$tmp/gh.log" XBPS_LOG="$tmp/xbps.log"
export GH_TOKEN=mock GH_REPO=rnicro/Monorepo PRIV_KEY='-----BEGIN PRIVATE KEY-----' SIGN_PASS=test-pass
export SIGNEDBY='rnicro <packages@example.invalid>' XBPS_TARGET_ARCH=x86_64-musl
export REPOSITORY_TAG=xbps-repository RUNNER_TEMP="$tmp"
: > "$GH_LOG"
: > "$XBPS_LOG"

cat > "$fake_bin/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$GH_LOG"
[[ "$1" == release ]] || exit 64
case "$2" in
  view)
    [[ -f "$GH_STATE/release-exists" ]]
    ;;
  download)
    destination=""
    while (($#)); do
      case "$1" in
        --dir) destination="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    [[ -n "$destination" ]]
    mkdir -p "$destination"
    cp -a "$GH_STATE/assets/." "$destination/"
    ;;
  create|upload)
    mode="$2"
    tag="$3"
    shift 3
    while (($#)); do
      case "$1" in
        --repo|--title|--notes) shift 2 ;;
        --clobber) shift ;;
        *)
          [[ -s "$1" ]] || { echo "missing mocked release asset: $1" >&2; exit 66; }
          cp -f "$1" "$GH_STATE/assets/$(basename "$1")"
          shift
          ;;
      esac
    done
    touch "$GH_STATE/release-exists"
    ;;
  *) exit 64 ;;
esac
GH
chmod +x "$fake_bin/gh"

cat > "$fake_bin/xbps-rindex" <<'XBPS'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$XBPS_LOG"
case "$1" in
  -a|--add|-r|--remove-obsoletes|-c|--clean)
    exit 0
    ;;
  --privkey)
    key="$2"
    mode="$3"
    shift 3
    [[ -s "$key" ]]
    case "$mode" in
      --sign)
        signedby=""
        repository=""
        while (($#)); do
          case "$1" in
            --signedby) signedby="$2"; shift 2 ;;
            *) repository="$1"; shift ;;
          esac
        done
        [[ -n "$signedby" && -d "$repository" ]]
        printf 'signedby=%s\n' "$signedby" > "$repository/${XBPS_TARGET_ARCH}-repodata"
        ;;
      --sign-pkg)
        for package in "$@"; do
          [[ -s "$package" ]]
          if [[ ! -s "${package}.sig2" ]]; then
            printf 'signature for %s\n' "$(basename "$package")" > "${package}.sig2"
          fi
        done
        ;;
      *) exit 64 ;;
    esac
    ;;
  *) exit 64 ;;
esac
XBPS
chmod +x "$fake_bin/xbps-rindex"
export PATH="$fake_bin:$PATH"

publish() {
  bash "$repo_root/maint/repository/scripts/publish-xbps-repository.sh" "$incoming"
}

printf 'alpha package v1\n' > "$incoming/alpha-1_1.x86_64-musl.xbps"
publish
[[ -f "$state/release-exists" ]]
[[ -s "$state/assets/alpha-1_1.x86_64-musl.xbps" ]]
[[ -s "$state/assets/alpha-1_1.x86_64-musl.xbps.sig2" ]]
[[ -s "$state/assets/x86_64-musl-repodata" ]]
[[ -s "$state/assets/SHA256SUMS" ]]
[[ "$(grep -c -- '--sign --signedby' "$XBPS_LOG")" -eq 1 ]]

# A later single-package publication must retain the previous package and
# update the same signed repository release.
rm -f "$incoming"/*.xbps
printf 'beta package v1\n' > "$incoming/beta-1_1.x86_64-musl.xbps"
publish
[[ -s "$state/assets/alpha-1_1.x86_64-musl.xbps" ]]
[[ -s "$state/assets/alpha-1_1.x86_64-musl.xbps.sig2" ]]
[[ -s "$state/assets/beta-1_1.x86_64-musl.xbps" ]]
[[ -s "$state/assets/beta-1_1.x86_64-musl.xbps.sig2" ]]
[[ "$(grep -c -- '--sign --signedby' "$XBPS_LOG")" -eq 1 ]]

# Never permit changed bytes under an already-published XBPS filename.
printf 'different alpha bytes\n' > "$incoming/alpha-1_1.x86_64-musl.xbps"
if publish >"$tmp/collision.log" 2>&1; then
  echo "publisher accepted changed bytes for an existing package filename" >&2
  exit 1
fi
grep -Fq 'Refusing to replace published package bytes' "$tmp/collision.log"
grep -Fq 'alpha package v1' "$state/assets/alpha-1_1.x86_64-musl.xbps"

echo "XBPS repository publication tests passed"

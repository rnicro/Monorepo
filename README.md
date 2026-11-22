# rnicro Void packages

An XBPS source package collection for Void Linux, targeting `x86_64-musl` and Intel Skylake where noted.

This repository is an overlay for [void-packages](https://github.com/void-linux/void-packages), not a fork. Recipes use Void's standard `srcpkgs/<package>/` layout.

## Packages

| Package | Purpose |
| --- | --- |
| [aria2](srcpkgs/aria2/) | CLI-only aria2; OpenSSL and Skylake tuning |
| [brightnessctl](srcpkgs/brightnessctl/) | brightnessctl with Skylake tuning |
| [librewolf](srcpkgs/librewolf/) | Native Wayland LibreWolf build |
| [linux7.3](srcpkgs/linux7.3/) | Linux 7.3 kernel and headers with a device-focused configuration |
| [tofi](srcpkgs/tofi/) | Wayland launcher; Meson/LTO and Skylake tuning |
| [velotype](srcpkgs/velotype/) | Native Rust/GPUI Markdown editor |
| [wlsunset](srcpkgs/wlsunset/) | Wayland colour-temperature tool |

All published packages target `x86_64-musl`. Packages using `-march=skylake` require an Intel Skylake-or-newer compatible CPU. The custom `linux7.3` configuration is hardware-specific; read [its package notes](docs/packages/linux.md) before installing.

## Signed XBPS repository

Successful manual builds are signed and published to one persistent GitHub Release:

```text
https://github.com/rnicro/Monorepo/releases/download/xbps-repository
```

Each package build updates the repository in place. Existing package archives are retained when they are still referenced by the XBPS index. The workflow rejects changed bytes under an already-published package filename; increment that package's `revision` before publishing changed output.

### 1. Create the signing key

XBPS remote repositories require an RSA private key in PEM format. Create an encrypted 4096-bit key on a trusted machine:

```sh
umask 077
openssl genrsa -des3 -out private.pem 4096
```

Choose a strong passphrase. Keep an offline backup of `private.pem`; **never commit it to this repository**.

### 2. Configure GitHub Actions

In **rnicro/Monorepo → Settings → Secrets and variables → Actions**, add:

| Name | Type | Value |
| --- | --- | --- |
| `PRIV_KEY` | Secret | Complete contents of `private.pem` |
| `SIGN_PASS` | Secret | Passphrase used when creating the key |
| `SIGNEDBY` | Variable | Signing identity shown by XBPS, e.g. `rnicro <you@example.com>` |

The publish job uses the repository's `GITHUB_TOKEN`. Ensure Actions is allowed to create/update releases and that the workflow's `contents: write` permission is enabled. Do not expose the private key or passphrase in workflow logs.

The repository key is initialized on the first publication. Keep the same private key and passphrase for future updates; replacing the key requires a coordinated repository/client trust-key migration.

### 3. Build and publish one package

Open **Actions → Validate and build XBPS packages → Run workflow**, select one package in the **Package** dropdown, and start the run.

The workflow validates the sources, builds only the selected package for `x86_64-musl`, signs its XBPS archive, refreshes the repository index, and updates the `xbps-repository` release. Pushes and pull requests run validation only; they do not publish packages.

### 4. Add the repository to a Void Linux system

Create an XBPS repository configuration file:

```sh
sudo install -d -m 0755 /etc/xbps.d
printf '%s\\n' \
  'repository=https://github.com/rnicro/Monorepo/releases/download/xbps-repository' \
  | sudo tee /etc/xbps.d/20-rnicro.conf
```

Synchronize the repository metadata:

```sh
sudo xbps-install -S
```

On first use, XBPS asks whether to trust the repository's signing key. Verify the displayed signer and key fingerprint through a trusted channel before accepting it. After the key is trusted, install or upgrade packages normally:

```sh
sudo xbps-install -Su
sudo xbps-install aria2
```

Replace `aria2` with `brightnessctl`, `librewolf`, `linux7.3`, `tofi`, `velotype`, or `wlsunset` as required. Review package notes and CPU/device restrictions before installing.

## Build locally

Clone the official Void build tree and this overlay:

```sh
git clone https://github.com/void-linux/void-packages.git
git clone https://github.com/rnicro/Monorepo.git rnicro-packages
cd rnicro-packages
pkg=tofi # choose one package
```

Prepare extra source inputs only for packages that need them:

```sh
# Velotype: download and verify its pinned source archive.
version="$(sed -n 's/^version=//p' srcpkgs/velotype/template)"
bash maint/velotype/scripts/prepare-source.sh \
  "../void-packages/hostdir/sources/velotype-$version"

# LibreWolf: fetch and verify Mozilla's pinned fallback source files.
bash maint/librewolf/scripts/prepare-source-fallbacks.sh
```

Overlay and build the selected recipe:

```sh
rm -rf "../void-packages/srcpkgs/$pkg"
cp -a "srcpkgs/$pkg" "../void-packages/srcpkgs/$pkg"
cd ../void-packages
./xbps-src -A x86_64-musl binary-bootstrap
./xbps-src -A x86_64-musl pkg "$pkg"
```

For LibreWolf and Velotype, run their preparation commands before overlaying the recipe. Packages are written to `hostdir/binpkgs/`.

## Repository layout

- `srcpkgs/<package>/`: canonical XBPS templates, patches, and package files.
- `maint/<package>/scripts/test-template.sh`: consistent package-template validation entry point.
- `maint/<package>/scripts/`: package-specific source preparation and focused tests.
- `maint/repository/scripts/`: signed repository publisher and its test.
- `docs/packages/`: package notes and hardware constraints.
- `examples/<package>/`: optional runtime configuration examples.

When updating recipes, follow Void's [package contribution guide](https://github.com/void-linux/void-packages/blob/master/CONTRIBUTING.md) and [manual](https://github.com/void-linux/void-packages/blob/master/Manual.md). Verify upstream source hashes and increment `revision` when packaging changes alter output for an unchanged upstream version.
